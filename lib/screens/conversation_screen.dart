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

import '../../api/apis.dart';
import '../../models/message.dart';
import '../../widgets/message_card.dart';
import '../services/cloudinary_service.dart';
import '../screens/friend_info_screen.dart';

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
  VideoPlayerController? _videoController;
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
    _videoController?.dispose();
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

  void _playVideo(String videoUrl) {
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
            child: FutureBuilder(
              future: _initializeVideoPlayer(videoUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                      IconButton(
                        icon: Icon(
                          isVideoPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40,
                          color: Colors.blueAccent,
                        ),
                        onPressed: _toggleVideoPlayback,
                      ),
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(videoUrl);
    await _videoController!.initialize();
    await _videoController!.setLooping(true);
    await _videoController!.play();
    setState(() {
      isVideoPlaying = true;
    });
  }

  void _toggleVideoPlayback() {
    if (_videoController != null) {
      if (isVideoPlaying) {
        _videoController?.pause();
      } else {
        _videoController?.play();
      }
      setState(() {
        isVideoPlaying = !isVideoPlaying;
      });
    }
  }

  void _playAudio(String audioUrl) {
    if (_currentPlayingAudioUrl == audioUrl && isAudioPlaying) {
      _audioPlayer.pause();
      setState(() {
        isAudioPlaying = false;
      });
    } else {
      _audioPlayer.setUrl(audioUrl).then((_) => _audioPlayer.play());
      _audioPlayer.playerStateStream.listen((playerState) {
        setState(() {
          isAudioPlaying = (playerState.playing);
          _currentPlayingAudioUrl = audioUrl;
        });
      });
    }
  }

  Widget _buildMessageItem(Message message) {
    final isMe = message.senderId == _currentUserId;
    final time = DateFormat('h:mm a').format(message.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: GestureDetector(
          onTap: () {
            if (message.type == MessageType.image) {
              _showFullScreenImage(message.content);
            } else if (message.type == MessageType.video) {
              _playVideo(message.content);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blueAccent : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.type == MessageType.image)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      message.content,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (message.type == MessageType.video)
                  _buildVideoThumbnail(message.content)
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
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
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
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _currentPlayingAudioUrl == audioUrl && isAudioPlaying 
                ? Icons.pause 
                : Icons.play_arrow,
            color: isMe ? Colors.white : Colors.black,
          ),
          onPressed: () => _playAudio(audioUrl),
        ),
        const Text('Audio Message', style: TextStyle(color: Colors.white)),
      ],
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