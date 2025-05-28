import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key, required Null Function(dynamic newGroup) onGroupCreated});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _friends = [];
  final List<Map<String, dynamic>> _selectedMembers = [];

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSelectingMembers = true;
  bool _isCreatingGroup = false; // NEW: To show loading spinner

  File? _groupImage;

  String _groupPrivacy = "All members can send messages";
  final List<String> _privacyOptions = [
    "All members can send messages",
    "Only admins can send messages"
  ];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final currentUser = _auth.currentUser!;
    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    final friendIDs = List<String>.from(userDoc.data()?['friends'] ?? []);

    final friends = await Future.wait(friendIDs.map((id) async {
      final doc = await _firestore.collection('users').doc(id).get();
      return {
        'uid': doc.id,
        'name': doc['name'],
        'about': doc['about'],
        'image': doc['image'],
      };
    }));

    setState(() {
      _friends = friends;
    });
  }

  void _toggleMemberSelection(Map<String, dynamic> friend) {
    setState(() {
      if (_selectedMembers.contains(friend)) {
        _selectedMembers.remove(friend);
      } else {
        _selectedMembers.add(friend);
      }
    });
  }

  void _goToGroupDetails() {
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one member")),
      );
      return;
    }
    setState(() => _isSelectingMembers = false);
  }

  Future<void> _pickGroupImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _groupImage = File(picked.path));
    }
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a group name")),
      );
      return;
    }

    setState(() => _isCreatingGroup = true); // Start loading

    String imageUrl = "";
    if (_groupImage != null) {
      imageUrl = await CloudinaryService.uploadImage(_groupImage!) ?? "";
    }

    final currentUser = _auth.currentUser!;
    final groupData = {
      'name': _groupNameController.text,
      'description': _descriptionController.text.isEmpty
          ? "No description provided."
          : _descriptionController.text,
      'privacy': _groupPrivacy,
      'image': imageUrl,
      'admin': currentUser.uid,
      'members': _selectedMembers.map((e) => e['uid']).toList(),
      'created_at': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection('groups').add(groupData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group created successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create group: $e")),
      );
    } finally {
      if (mounted) setState(() => _isCreatingGroup = false); // Stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              _isSelectingMembers
                  ? "Select Members (${_selectedMembers.length})"
                  : "Group Details",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blueAccent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: _isSelectingMembers ? _buildSelectMembers() : _buildGroupDetails(),
          floatingActionButton: _isSelectingMembers
              ? FloatingActionButton(
                  backgroundColor: Colors.blueAccent,
                  onPressed: _goToGroupDetails,
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                )
              : null,
        ),
        if (_isCreatingGroup)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectMembers() {
    return _friends.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(8),
            children: [
              if (_selectedMembers.isNotEmpty)
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedMembers.length,
                    itemBuilder: (context, index) {
                      final member = _selectedMembers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.blueAccent, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(member['image']),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              child: Text(
                                member['name'],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const Divider(),
              ..._friends.map((friend) {
                final isSelected = _selectedMembers.contains(friend);
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(friend['image'])),
                  title: Text(friend['name']),
                  subtitle: Text(friend['about']),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.blueAccent : Colors.grey,
                  ),
                  onTap: () => _toggleMemberSelection(friend),
                );
              }),
            ],
          );
  }

  Widget _buildGroupDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickGroupImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _groupImage != null
                  ? FileImage(_groupImage!)
                  : const AssetImage("assets/default_group.png") as ImageProvider,
              child: _groupImage == null
                  ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: "Group Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Group Description",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _groupPrivacy,
            decoration: const InputDecoration(
              labelText: "Group Privacy",
              border: OutlineInputBorder(),
            ),
            items: _privacyOptions.map((privacy) {
              return DropdownMenuItem(value: privacy, child: Text(privacy));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _groupPrivacy = value);
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _isSelectingMembers = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Back", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Create", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
