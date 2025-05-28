import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cloudinary_service.dart';

class AddStatusScreen extends StatefulWidget {
  const AddStatusScreen({super.key});

  @override
  _AddStatusScreenState createState() => _AddStatusScreenState();
}

class _AddStatusScreenState extends State<AddStatusScreen> with TickerProviderStateMixin {
  final TextEditingController _statusController = TextEditingController();
  String? _selectedFilePath;
  String? _fileType;
  bool _isUploading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _submitStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final statusText = _statusController.text.trim();
    if (statusText.isEmpty && _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a status or select a file.")),
      );
      return;
    }

    setState(() => _isUploading = true);
    String? mediaUrl;

    try {
      if (_selectedFilePath != null) {
        final file = File(_selectedFilePath!);
        if (_fileType == "image") {
          mediaUrl = await CloudinaryService.uploadImage(file);
        } else if (_fileType == "video") {
          mediaUrl = await CloudinaryService.uploadVideo(file);
        } else if (_fileType == "audio") {
          mediaUrl = await CloudinaryService.uploadAudio(file);
        }
      }

      await FirebaseFirestore.instance.collection('statuses').add({
        'userId': user.uid,
        'text': statusText,
        'mediaUrl': mediaUrl,
        'mediaType': _fileType,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickFile(String type) async {
    FileType fileType;
    if (type == "image") {
      fileType = FileType.image;
    } else if (type == "video") {
      fileType = FileType.video;
    } else if (type == "audio") {
      fileType = FileType.audio;
    } else {
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowMultiple: false,
      withData: false,
      withReadStream: true,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _fileType = type;
      });
    }
  }

  void _showFilePickerMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SlideTransition(
          position: _slideAnimation,
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.image, color: Colors.blueAccent),
                title: Text("Add Image"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile("image");
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: Colors.blueAccent),
                title: Text("Add Video"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile("video");
                },
              ),
              ListTile(
                leading: Icon(Icons.mic, color: Colors.blueAccent),
                title: Text("Add Audio"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile("audio");
                },
              ),
            ],
          ),
        );
      },
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Status", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: mediaQuery.viewInsets.bottom + 16,
                top: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("What's on your mind?",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _statusController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Type your status here...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedFilePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Chip(
                        label: Text(
                          _selectedFilePath!.split('/').last,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.blueAccent,
                        onDeleted: () {
                          setState(() {
                            _selectedFilePath = null;
                            _fileType = null;
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _submitStatus,
                      icon: const Icon(Icons.send),
                      label: Text(_isUploading ? "Posting..." : "Post Status"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilePickerMenu,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
