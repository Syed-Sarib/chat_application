import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupScreen extends StatefulWidget {
  final Function(Map<String, String>) onGroupCreated;

  const CreateGroupScreen({required this.onGroupCreated, super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final List<Map<String, String>> _friends = [
    {"name": "Ali", "about": "Loves traveling", "image": "https://i.pravatar.cc/150?img=1"},
    {"name": "Ahmad", "about": "Software Engineer", "image": "https://i.pravatar.cc/150?img=2"},
    {"name": "Sarah", "about": "Food Blogger", "image": "https://i.pravatar.cc/150?img=3"},
    {"name": "Ayesha", "about": "Photographer", "image": "https://i.pravatar.cc/150?img=4"},
    {"name": "Hassan", "about": "Gamer", "image": "https://i.pravatar.cc/150?img=5"},
  ];

  final List<Map<String, String>> _selectedMembers = [];
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSelectingMembers = true;

  String _groupPrivacy = "All members can send messages";
  final List<String> _privacyOptions = [
    "All members can send messages",
    "Only admins can send messages"
  ];

  File? _groupImage;

  void _toggleMemberSelection(Map<String, String> friend) {
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
    setState(() {
      _isSelectingMembers = false;
    });
  }

  void _createGroup() {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a group name")),
      );
      return;
    }

    final newGroup = {
      "name": _groupNameController.text,
      "message": _descriptionController.text.isEmpty
          ? "No description provided."
          : _descriptionController.text,
      "privacy": _groupPrivacy,
      "time": "Just now",
      "image": _groupImage?.path ?? "",
    };

    widget.onGroupCreated(newGroup);
    Navigator.pop(context);
  }

  Future<void> _pickGroupImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _groupImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(
          _isSelectingMembers ? Icons.arrow_forward : Icons.check,
          color: Colors.white,
        ),
        onPressed: _isSelectingMembers ? _goToGroupDetails : _createGroup,
      ),
    );
  }

  Widget _buildSelectMembers() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_selectedMembers.isNotEmpty)
            SizedBox(
              height: 110,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMembers.length,
                  itemBuilder: (context, index) {
                    final member = _selectedMembers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blueAccent, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(member["image"]!),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60,
                            child: Text(
                              member["name"]!,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _friends.length,
            itemBuilder: (context, index) {
              final friend = _friends[index];
              final isSelected = _selectedMembers.contains(friend);
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend["image"]!),
                ),
                title: Text(friend["name"]!),
                subtitle: Text(friend["about"]!),
                trailing: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Colors.blueAccent : Colors.grey,
                ),
                onTap: () => _toggleMemberSelection(friend),
              );
            },
          ),
        ],
      ),
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
              return DropdownMenuItem<String>(
                value: privacy,
                child: Text(privacy),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _groupPrivacy = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSelectingMembers = true;
                  });
                },
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
