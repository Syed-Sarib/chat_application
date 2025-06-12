import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_group_screen.dart';
import 'group_conversation_screen.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isSearchMode = false;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _openCreateGroupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateGroupScreen(
          onGroupCreated: (newGroup) {
            setState(() {}); // Trigger rebuild if needed
          },
        ),
      ),
    ).then((_) {
      // Refresh the page when returning
      setState(() {});
    });
  }

  Future<List<QueryDocumentSnapshot>> _fetchGroups() async {
    // Query groups where the user is a member
    final memberGroups = await FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: currentUserId)
        .get();

    // Query groups where the user is an admin
    final adminGroups = await FirebaseFirestore.instance
        .collection('groups')
        .where('admin', isEqualTo: currentUserId)
        .get();

    // Combine the results and remove duplicates
    final allGroups = [...memberGroups.docs, ...adminGroups.docs];
    final uniqueGroups = {for (var group in allGroups) group.id: group}.values.toList();

    // Sort groups by recentTimestamp in descending order
    uniqueGroups.sort((a, b) {
      final aTimestamp = (a.data())['recentTimestamp'] as Timestamp?;
      final bTimestamp = (b.data())['recentTimestamp'] as Timestamp?;
      return (bTimestamp?.compareTo(aTimestamp ?? Timestamp(0, 0)) ?? 0);
    });

    return uniqueGroups;
  }

  Future<void> _triggerSearchMode() async {
    setState(() {
      _isSearchMode = true;
    });
  }

  void _exitSearchMode() {
    setState(() {
      _isSearchMode = false;
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  void _deleteGroup(String groupId) async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group deleted successfully')),
      );
      setState(() {}); // Refresh the page after deleting the group
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete group')),
      );
    }
  }

  String _formatDate(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Yesterday";
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('hh:mm a').format(date);
  }

  String _getMessagePreview(Map<String, dynamic> groupData) {
    if (groupData['recentMessage'] == null || groupData['recentMessage'].toString().isEmpty) {
      return "No messages yet";
    }

    final messageUrl = groupData['recentMessage'].toString();
    if (messageUrl.contains('/image/upload/')) {
      return '📷 Photo';
    } else if (messageUrl.contains('/video/upload/')) {
      return '🎥 Video';
    } else if (messageUrl.contains('/raw/upload/')) {
      if (messageUrl.toLowerCase().endsWith('.mp3') ||
          messageUrl.toLowerCase().contains('.wav') ||
          messageUrl.toLowerCase().contains('.aac')) {
        return '🎵 Audio';
      } else {
        return '📄 File';
      }
    }

    return groupData['recentMessage'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search Groups...",
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text(
                'Groups',
                style: TextStyle(color: Colors.white,fontSize: 25, fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (_isSearchMode)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _exitSearchMode,
            ),
          if (!_isSearchMode)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _triggerSearchMode,
            ),
        ],
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No groups found.'));
          }

          final groups = snapshot.data!.where((doc) {
            final groupData = doc.data() as Map<String, dynamic>;
            final groupName = groupData['name']?.toLowerCase() ?? "";
            return groupName.contains(_searchQuery);
          }).toList();

          if (groups.isEmpty) {
            return const Center(child: Text('No matching groups found.'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupData = group.data() as Map<String, dynamic>;

              return GestureDetector(
                onLongPress: () {
                  if (groupData['admin'] == currentUserId) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Group'),
                        content: const Text('Are you sure you want to delete this group?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteGroup(group.id);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: groupData['image'] != null && groupData['image'].isNotEmpty
                          ? NetworkImage(groupData['image'])
                          : null,
                      child: groupData['image'] == null || groupData['image'].isEmpty
                          ? const Icon(Icons.group, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      groupData['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _getMessagePreview(groupData),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: groupData['recentTimestamp'] != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(groupData['recentTimestamp']),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                _formatTime(groupData['recentTimestamp']),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => GroupConversationScreen(
                            groupId: group.id,
                            groupName: groupData['name'],
                            groupImageUrl: groupData['image'],
                            participants: List<String>.from(groupData['members'] ?? []),
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0); // Start from the bottom of the screen
                            const end = Offset.zero; // End at the current position
                            const curve = Curves.easeInOutCubicEmphasized;

                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      ).then((_) {
                        setState(() {}); // Refresh the page when returning
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _openCreateGroupScreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}