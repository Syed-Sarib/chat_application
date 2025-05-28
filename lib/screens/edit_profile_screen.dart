import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cloudinary_service.dart'; // UPDATED: Import CloudinaryService

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentDescription;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentDescription,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  File? _avatarImage;
  bool _isPickingImage = false;
  bool _isSaving = false;
  String _errorText = '';

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _descriptionController = TextEditingController(text: widget.currentDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _avatarImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Image pick error: $e');
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    final updatedName = _nameController.text.trim();
    final updatedDescription = _descriptionController.text.trim();
    final currentUser = _auth.currentUser;

    if (updatedName.isEmpty) {
      setState(() => _errorText = 'Name cannot be empty');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = '';
    });

    try {
      // Check if name is unique
      final existing = await _firestore
          .collection('users')
          .where('name', isEqualTo: updatedName)
          .get();

      final isNameUsedByOthers = existing.docs.any((doc) => doc.id != currentUser!.uid);

      if (isNameUsedByOthers) {
        setState(() {
          _isSaving = false;
          _errorText = 'This name is already taken. Choose another one.';
        });
        return;
      }

      // Upload image to Cloudinary and get the URL
      String? imageUrl;
      if (_avatarImage != null) {
        imageUrl = await CloudinaryService.uploadImage(_avatarImage!);
        if (imageUrl == null) {
          setState(() {
            _isSaving = false;
            _errorText = 'Failed to upload image. Try again.';
          });
          return;
        }
      }

      // Save to Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'name': updatedName,
        'about': updatedDescription,
        if (imageUrl != null) 'image': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, {
          'name': updatedName,
          'description': updatedDescription,
          'avatar': _avatarImage,
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _errorText = 'Failed to update profile. Try again.');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _avatarImage != null
                    ? FileImage(_avatarImage!)
                    : const AssetImage("assets/images/default_avatar.png") as ImageProvider,
                child: _avatarImage == null
                    ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_errorText, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
