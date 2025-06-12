import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'friend_info_screen.dart';

class SearchFriendScreen extends StatefulWidget {
  const SearchFriendScreen({super.key});

  @override
  State<SearchFriendScreen> createState() => _SearchFriendScreenState();
}

class _SearchFriendScreenState extends State<SearchFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _filteredFriends = [];
  bool _isLoading = false;
  String? currentUserId;

  // Lists to exclude users
  List<dynamic> currentUserFriends = [];
  List<dynamic> friendRequestsSent = [];
  List<dynamic> friendRequestsReceived = [];

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      final data = userDoc.data();
      if (data != null) {
        currentUserFriends = data['friends'] ?? [];
        friendRequestsSent = data['friendRequestsSent'] ?? [];
        friendRequestsReceived = data['friendRequestsReceived'] ?? [];
      }
    }
  }

  void _filterFriends(String query) async {
    if (currentUserId == null || query.trim().isEmpty) {
      setState(() {
        _filteredFriends = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final filtered = snapshot.docs.where((doc) {
        final docId = doc.id;
        return docId != currentUserId &&
            !currentUserFriends.contains(docId) &&
            !friendRequestsSent.contains(docId) &&
            !friendRequestsReceived.contains(docId);
      }).toList();

      setState(() {
        _filteredFriends = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Friend",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _filterFriends,
              decoration: InputDecoration(
                hintText: "Search for a friend...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterFriends('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            Expanded(
              child: _filteredFriends.isEmpty
                  ? const Center(child: Text("No users found."))
                  : ListView.builder(
                      itemCount: _filteredFriends.length,
                      itemBuilder: (context, index) {
                        var friendData = _filteredFriends[index].data() as Map<String, dynamic>;
                        final friendId = _filteredFriends[index].id;
                        final name = friendData['name'] ?? 'Unknown';
                        final imageUrl = friendData['profileImageUrl'] ??
                            'https://example.com/default-avatar.png';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                          title: Text(name),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendInfoScreen(
                                  friendId: friendId,
                                  friendName: name,
                                  friendImageUrl: imageUrl,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
