import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:chewie/chewie.dart';
import 'edit_group_screen.dart';
import '../widgets/audio_message_player.dart';
import '../../models/user.dart'; // Your UserModel class
import '../../services/cloudinary_service.dart';

class GroupConversationScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImageUrl;
  final List<String> participants;

  const GroupConversationScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
    required this.participants,
  });

  @override
  _GroupConversationScreenState createState() => _GroupConversationScreenState();
}

class _GroupConversationScreenState extends State<GroupConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // For media playback
  ChewieController? _chewieController;
  bool isVideoPlaying = false;
  bool isAudioPlaying = false;
  String? _currentPlayingAudioUrl;

  final bool _isRecording = false;
  final bool _isDeleting = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late String groupName;
  late String groupImageUrl;
  late List<String> participants;

  @override
  void initState() {
    super.initState();
    groupName = widget.groupName;
    groupImageUrl = widget.groupImageUrl;
    participants = widget.participants;
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.openRecorder();
  }

  Future<void> _refreshGroupDetails() async {
    try {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
      if (groupDoc.exists) {
        setState(() {
          groupName = groupDoc['name'];
          groupImageUrl = groupDoc['image'];
          participants = List<String>.from(groupDoc['members'] ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh group details: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.closeRecorder();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? content, String type = 'text'}) async {
    if (content == null && _controller.text.trim().isEmpty) return;

    final currentUser = await UserModel.getUserById(currentUserId);
    final timestamp = Timestamp.now();

    try {
      // Add message to messages subcollection
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'senderName': currentUser?.name ?? 'Unknown',
        'senderAvatar': currentUser?.image ?? '',
        'content': content ?? _controller.text.trim(),
        'timestamp': timestamp,
        'type': type,
      });

      // Update group's recent message
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'recentMessage': content ?? _controller.text.trim(),
        'recentTimestamp': timestamp,
      });

      if (content == null) {
        _controller.clear();
      }
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndSendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final url = await CloudinaryService.uploadFile(file);
        final fileType = result.files.first.extension?.toLowerCase();

        if (fileType != null) {
          if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileType)) {
            await _sendMessage(content: url, type: 'image');
          } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(fileType)) {
            await _sendMessage(content: url, type: 'video');
          } else if (['mp3', 'wav', 'm4a', 'aac'].contains(fileType)) {
            await _sendMessage(content: url, type: 'audio');
          } else {
            await _sendMessage(content: url, type: 'file');
          }
        } else {
          await _sendMessage(content: url, type: 'file');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send file: $e')),
      );
    }
  }

  Widget _buildMessageBubble(DocumentSnapshot messageDoc) {
    final message = messageDoc.data() as Map<String, dynamic>;
    final isMe = message['senderId'] == currentUserId;
    final time = message['timestamp'] != null
        ? DateFormat('h:mm a').format((message['timestamp'] as Timestamp).toDate())
        : 'Unknown time';

    return FutureBuilder<UserModel?>(
      future: UserModel.getUserById(message['senderId'] ?? ''),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe && user?.image != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: user?.image != null && user!.image.isNotEmpty
                        ? NetworkImage(user.image)
                        : const AssetImage("assets/default_avatar.png") as ImageProvider,
                  ),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          user?.name ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onLongPress: () => _deleteMessage(messageDoc),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isMe
                                ? const Radius.circular(12)
                                : const Radius.circular(4),
                            bottomRight: isMe
                                ? const Radius.circular(4)
                                : const Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message['type'] == 'image')
                              GestureDetector(
                                onTap: () => _showFullScreenImage(message['content']),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    message['content'],
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (message['type'] == 'video')
                              GestureDetector(
                                onTap: () => _playVideo(message['content']),
                                child: _buildVideoThumbnail(message['content']),
                              )
                            else if (message['type'] == 'audio')
                              _buildAudioPlayer(message['content'], isMe)
                            else if (message['type'] == 'file')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.insert_drive_file, size: 40),
                                  Text(
                                    'File Attachment',
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              )
                            else
                              IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message['content'] ?? 'No content',
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          time,
                                          style: TextStyle(
                                            color: isMe ? Colors.white70 : Colors.black54,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMe && user?.image != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: user?.image != null && user!.image.isNotEmpty
                        ? NetworkImage(user.image)
                        : const AssetImage("assets/default_avatar.png") as ImageProvider,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          color: Colors.black,
          child: FutureBuilder(
            future: _getVideoThumbnail(videoUrl),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Image.network(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        const Icon(Icons.play_circle_filled, size: 50, color: Colors.white),
      ],
    );
  }

  Future<String> _getVideoThumbnail(String videoUrl) async {
    if (videoUrl.contains('cloudinary.com')) {
      return videoUrl.replaceAll(RegExp(r'\.(mp4|mov|avi|mkv|webm)$'), '.jpg');
    }
    return 'https://via.placeholder.com/200x200?text=Video';
  }

  Widget _buildAudioPlayer(String audioUrl, bool isMe) {
  return AudioMessagePlayer(
    audioUrl: audioUrl,
    isMe: isMe,
  );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }

  void _playVideo(String videoUrl) async {
    final videoController = VideoPlayerController.network(videoUrl);
    await videoController.initialize();
    
    final chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: true,
      looping: true,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SafeArea(
            child: Chewie(
              controller: chewieController,
            ),
          ),
        ),
      ),
    ).then((_) {
      videoController.dispose();
      chewieController.dispose();
    });
  }

  void _playAudio(String audioUrl) async {
    if (_currentPlayingAudioUrl == audioUrl && isAudioPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isAudioPlaying = false;
      });
    } else {
      try {
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
        setState(() {
          isAudioPlaying = true;
          _currentPlayingAudioUrl = audioUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play audio: $e')),
        );
      }
    }
  }

  Future<void> _deleteMessage(DocumentSnapshot messageDoc) async {
    final message = messageDoc.data() as Map<String, dynamic>;
    if (message['senderId'] != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own messages')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .doc(messageDoc.id)
            .delete();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: $e')),
        );
      }
    }
  }

  Future<List<String>> _getParticipantNames() async {
    try {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
      if (!groupDoc.exists) {
        print('Group document does not exist.');
        return [];
      }

      final memberIds = List<String>.from(groupDoc['members'] ?? []);
      print('Member IDs: $memberIds');

      final userFutures = memberIds.map((id) => UserModel.getUserById(id)).toList();
      final userDocs = await Future.wait(userFutures);

      final memberNames = userDocs.map((user) => user?.name ?? 'Unknown').toList();
      print('Member Names: $memberNames');

      return memberNames;
    } catch (e) {
      print('Error fetching member names: $e');
      return Future.error('Failed to load members');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(groupImageUrl),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<List<String>>(
                    future: _getParticipantNames(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Loading...',
                          style: TextStyle(fontSize: 12),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          'Error loading members',
                          style: TextStyle(fontSize: 12),
                        );
                      }

                      final memberNames = snapshot.data ?? [];
                      final otherMembers = memberNames.where((name) => name != 'You').toList();
                      final memberCount = otherMembers.length;

                      return Text(
                        'You and $memberCount members (${otherMembers.join(', ')})',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit_group') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGroupScreen(
                      groupId: widget.groupId,
                      groupName: groupName,
                      groupImageUrl: groupImageUrl,
                      participants: participants,
                    ),
                  ),
                );

                if (result == true) {
                  // Refresh group details after editing
                  _refreshGroupDetails();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_group',
                child: Text('Edit Group'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Start the conversation!'),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(snapshot.data!.docs[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickAndSendFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}