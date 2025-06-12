import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:chewie/chewie.dart';

import '../../api/apis.dart';
import '../../models/message.dart';
import '../services/cloudinary_service.dart';
import '../screens/friend_info_screen.dart';
import '../widgets/audio_message_player.dart';
class ConversationScreen extends StatefulWidget {
  final String chatId;
  final String userId;

  const ConversationScreen({
    super.key,
    required this.chatId,
    required this.userId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();

  final bool _isRecording = false;
  final bool _isDeleting = false;
  late String userName = '';
  late String userPic = '';
  late bool isOnline = false;
  late DateTime lastActive = DateTime.now();
  String? _currentUserId;
  
  // For media playback
  ChewieController? _chewieController;
  bool isVideoPlaying = false;
  bool isAudioPlaying = false;
  String? _currentPlayingAudioUrl;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _getUserDetails();
    _initCurrentUser();
  }

  Future<void> _initCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUserId = APIs.user?.uid ?? firebaseUser?.uid;
    });

    if (_currentUserId == null) {
      print('Warning: No current user ID found');
    }
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.openRecorder();
  }

  Future<void> _getUserDetails() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'Unknown';
          userPic = userDoc['image'] ?? '';
          isOnline = userDoc['is_online'] ?? false;
          lastActive = userDoc['last_active']?.toDate() ?? DateTime.now();
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.closeRecorder();
    _chewieController?.dispose();
    super.dispose();
  }

  void _sendMessage({String? content, MessageType type = MessageType.text}) async {
    if (_currentUserId == null) {
      print('Cannot send message - no current user ID');
      return;
    }

    if ((content != null && content.trim().isNotEmpty) || type != MessageType.text) {
      final message = Message(
        id: const Uuid().v4(),
        senderId: _currentUserId!,
        content: content ?? '',
        type: type,
        timestamp: DateTime.now(),
        seen: false,
        delivered: false,
      );

      await APIs.sendMessage(widget.chatId, widget.userId, message);
      _textController.clear();
      _scrollToBottom();
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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final url = await CloudinaryService.uploadFile(file);
        final fileType = result.files.first.extension?.toLowerCase();

        if (fileType != null) {
          if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileType)) {
            _sendMessage(content: url, type: MessageType.image);
          } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(fileType)) {
            _sendMessage(content: url, type: MessageType.video);
          } else if (['mp3', 'wav', 'm4a', 'aac'].contains(fileType)) {
            _sendMessage(content: url, type: MessageType.audio);
          } else {
            _sendMessage(content: url, type: MessageType.file);
          }
        } else {
          _sendMessage(content: url, type: MessageType.file);
        }
      }
    } catch (e) {
      print('File picking error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send file: $e')),
      );
    }
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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

  Future<void> _playVideo(String videoUrl) async {
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
             titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            foregroundColor: Colors.white,
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

  Future<void> _deleteMessage(Message message) async {
    if (message.senderId != _currentUserId) {
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
        await APIs.deleteMessage(widget.chatId, message.id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: $e')),
        );
      }
    }
  }

  Widget _buildMessageItem(Message message) {
    final isMe = message.senderId == _currentUserId;
    final time = DateFormat('h:mm a').format(message.timestamp);

    return GestureDetector(
      onLongPress: () => _deleteMessage(message),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.blueAccent : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.type == MessageType.image)
                    GestureDetector(
                      onTap: () => _showFullScreenImage(message.content),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.content,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else if (message.type == MessageType.video)
                    GestureDetector(
                      onTap: () => _playVideo(message.content),
                      child: _buildVideoThumbnail(message.content),
                    )
                  else if (message.type == MessageType.audio)
                    _buildAudioPlayer(message.content, isMe)
                  else if (message.type == MessageType.file)
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
                            message.content,
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
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendInfoScreen(
                      friendId: widget.userId,
                      friendName: userName,
                      friendImageUrl: userPic,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(userPic),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName),
                Text(
                  isOnline
                      ? 'Online'
                      : 'Last Active: ${lastActive.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: APIs.getAllMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final messages = docs
                    .map((doc) {
                      try {
                        return Message.fromJson(doc.data());
                      } catch (e) {
                        print("Error parsing message: $e");
                        return null;
                      }
                    })
                    .whereType<Message>()
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(messages[index]);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) => _sendMessage(content: value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(content: _textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}