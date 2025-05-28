import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/cloudinary_service.dart';

class EditGroupScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImageUrl;
  final List<String> participants;

  const EditGroupScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
    required this.participants,
  });

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  late List<Map<String, dynamic>> _members;
  late List<Map<String, dynamic>> _friends;
  File? _groupImage;
  String _groupPrivacy = "All members can send messages";
  final List<String> _privacyOptions = [
    "All members can send messages",
    "Only admins can send messages"
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.groupName;
    _descriptionController.text = ""; // Initialize description if needed
    _members = []; // Initialize _members as an empty list
    _friends = []; // Initialize _friends as an empty list
    _loadMembers(); // Load members asynchronously
    _loadFriends(); // Load friends asynchronously
  }

  Future<void> _loadMembers() async {
    final members = await Future.wait(widget.participants.map((id) async {
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      return {
        'uid': doc.id,
        'name': doc['name'] ?? 'Unknown',
        'about': doc['about'] ?? 'No description available',
        'image': doc['image'] ?? '',
      };
    }));

    setState(() {
      _members = members;
    });
  }

  Future<void> _loadFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final friendIDs = List<String>.from(userDoc.data()?['friends'] ?? []);

    final friends = await Future.wait(friendIDs.map((id) async {
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      return {
        'uid': doc.id,
        'name': doc['name'] ?? 'Unknown',
        'about': doc['about'] ?? 'No description available',
        'image': doc['image'] ?? '',
      };
    }));

    setState(() {
      _friends = friends;
    });
  }

  Future<void> _pickGroupImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _groupImage = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    try {
      String imageUrl = widget.groupImageUrl;
      if (_groupImage != null) {
        imageUrl = await CloudinaryService.uploadImage(_groupImage!) ?? widget.groupImageUrl;
      }

      await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'privacy': _groupPrivacy,
        'image': imageUrl,
        'members': _members.map((e) => e['uid']).toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group updated successfully')),
      );
      Navigator.pop(context, true); // Pass true to indicate changes were made
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update group: $e')),
      );
    }
  }

  void _addMemberByUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userDoc = userSnapshot.docs.first;
      final userId = userDoc.id;
      final userData = {
        'uid': userId,
        'name': userDoc['name'] ?? 'Unknown',
        'about': userDoc['about'] ?? 'No description available',
        'image': userDoc['image'] ?? '',
      };

      if (!_members.any((member) => member['uid'] == userId)) {
        setState(() {
          _members.add(userData);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is already a member')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
    }
  }

  void _addMemberFromFriends(Map<String, dynamic> friend) {
    if (!_members.any((member) => member['uid'] == friend['uid'])) {
      setState(() {
        _members.add(friend);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is already a member')),
      );
    }
  }

  void _removeMember(String memberId) {
    setState(() {
      _members.removeWhere((member) => member['uid'] == memberId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Edit Group'),
            backgroundColor: Colors.blueAccent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickGroupImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _groupImage != null
                        ? FileImage(_groupImage!)
                        : NetworkImage(widget.groupImageUrl),
                    child: _groupImage == null
                        ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
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
                    const Text(
                      'Members',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Add Member',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    labelText: "Add by Username",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _addMemberByUsername,
                                  child: const Text('Add by Username'),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Add from Friends',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _friends.length,
                                    itemBuilder: (context, index) {
                                      final friend = _friends[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: friend['image'].isNotEmpty
                                              ? NetworkImage(friend['image'])
                                              : const AssetImage("assets/default_avatar.png")
                                                  as ImageProvider,
                                        ),
                                        title: Text(friend['name']),
                                        subtitle: Text(friend['about']),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add_circle, color: Colors.green),
                                          onPressed: () => _addMemberFromFriends(friend),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: member['image'].isNotEmpty
                              ? NetworkImage(member['image'])
                              : const AssetImage("assets/default_avatar.png") as ImageProvider,
                        ),
                        title: Text(member['name']),
                        subtitle: Text(member['about']),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeMember(member['uid']),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}