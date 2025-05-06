import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupConversationScreen extends StatefulWidget {
  final String groupName;
  final String groupImageUrl;
  final List<Map<String, String>> participants;

  const GroupConversationScreen({
    super.key,
    required this.groupName,
    required this.groupImageUrl,
    required this.participants,
  });

  @override
  _GroupConversationScreenState createState() => _GroupConversationScreenState();
}

class _GroupConversationScreenState extends State<GroupConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool _isRecording = false;
  bool _isCancelled = false;
  double _dragDistance = 0.0;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final Random _random = Random();
  Timer? _spectrumTimer;
  List<double> _spectrumHeights = List.generate(10, (_) => 10.0);

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _player.openPlayer();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _recorder.openRecorder();
      await Permission.microphone.request();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize recorder: $e')),
      );
    }
  }

  void _startRecording() async {
    PermissionStatus status = await Permission.microphone.request();

    if (status.isGranted) {
      if (_recorder.isStopped) {
        await _recorder.openRecorder();
      }

      setState(() {
        _isRecording = true;
        _isCancelled = false;
        _dragDistance = 0.0;
        _recordingSeconds = 0;
      });

      try {
        await _recorder.startRecorder(toFile: 'voice_note.aac');

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingSeconds++;
          });
        });

        _spectrumTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          setState(() {
            _spectrumHeights = List.generate(
              10,
              (_) => _random.nextDouble() * 30 + 10,
            );
          });
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
        setState(() {
          _isRecording = false;
        });
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required to record audio.')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is permanently denied. Please enable it in settings.')),
      );
    }
  }

  void _cancelRecording() async {
    setState(() {
      _isRecording = false;
      _isCancelled = true;
    });

    await _recorder.stopRecorder();
    _recordingTimer?.cancel();
    _spectrumTimer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recording canceled.')),
    );
  }

  void _sendVoiceNote() async {
    if (!_isCancelled) {
      try {
        final path = await _recorder.stopRecorder();
        if (path != null) {
          setState(() {
            messages.add({
              "sender": "Me",
              "type": "voice",
              "path": path.toString(),
              "time": "Just Now",
            });
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to retrieve recording path.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
    }

    setState(() {
      _isRecording = false;
    });

    _recordingTimer?.cancel();
    _spectrumTimer?.cancel();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({
          "sender": "Me",
          "type": "text",
          "message": _controller.text,
          "time": "Just Now",
        });
      });
      _controller.clear();
    }
  }

  Widget _buildTextMessage(Map<String, String> message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message["sender"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            Text(
              message["message"] ?? "",
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message["time"] ?? "",
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSpectrum() {
    final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Text(
            "$minutes:$seconds",
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: List.generate(
                _spectrumHeights.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 5,
                  height: _spectrumHeights[index],
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildOptionButton(Icons.image, "Gallery"),
              _buildOptionButton(Icons.camera_alt, "Image"),
              _buildOptionButton(Icons.audiotrack, "Audio"),
              _buildOptionButton(Icons.videocam, "Video"),
              _buildOptionButton(Icons.insert_drive_file, "Document"),
              _buildOptionButton(Icons.location_on, "Location"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blueAccent.withOpacity(0.2),
          child: Icon(icon, color: Colors.blueAccent, size: 30),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.groupImageUrl),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.groupName,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'add') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Participant feature coming soon!')),
                );
              } else if (value == 'leave') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Leave Group feature coming soon!')),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'add',
                child: Text('Add Participant'),
              ),
              const PopupMenuItem(
                value: 'leave',
                child: Text('Leave Group'),
              ),
            ],
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isMe = message["sender"] == "Me";
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: _buildTextMessage(message, isMe),
                  ),
                );
              },
            ),
          ),
          if (_isRecording) _buildVoiceSpectrum(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _isRecording ? "Slide left to cancel" : "Type a message",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.grey[700]),
                            onPressed: _showAddOptions,
                          ),
                          GestureDetector(
                            onLongPress: _startRecording,
                            onLongPressUp: () {
                              if (_dragDistance < -100) {
                                _cancelRecording();
                              } else {
                                _sendVoiceNote();
                              }
                            },
                            onHorizontalDragUpdate: (details) {
                              setState(() {
                                _dragDistance += details.delta.dx;
                                if (_dragDistance < -100) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Slide left to cancel recording.')),
                                  );
                                }
                              });
                            },
                            child: Icon(
                              Icons.mic,
                              color: _isRecording ? Colors.red : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.translate, color: Colors.blueAccent),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI Translate feature coming soon!')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _recordingTimer?.cancel();
    _spectrumTimer?.cancel();
    super.dispose();
  }
}