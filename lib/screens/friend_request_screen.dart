import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> _acceptRequest(String senderId) async {
    if (currentUser == null) return;

    try {
      final currentUserRef = _firestore.collection('users').doc(currentUser!.uid);
      final senderRef = _firestore.collection('users').doc(senderId);

      // Start a batch to perform multiple writes atomically
      WriteBatch batch = _firestore.batch();

      // Add sender to the current user's friends list (create if not exists)
      batch.update(currentUserRef, {
        'friends': FieldValue.arrayUnion([senderId]),
      });

      // Add current user to the sender's friends list (create if not exists)
      batch.update(senderRef, {
        'friends': FieldValue.arrayUnion([currentUser!.uid]),
      });

      // Delete the friend request
      batch.delete(
        _firestore.collection('friend_requests')
            .doc(currentUser!.uid)
            .collection('requests')
            .doc(senderId),
      );

      // Commit the batch
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Friend request accepted!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _rejectRequest(String senderId) async {
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('friend_requests')
          .doc(currentUser!.uid)
          .collection('requests')
          .doc(senderId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Friend request rejected!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('friend_requests')
            .doc(currentUser!.uid)
            .collection('requests')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No friend requests"));
          }

          var requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index].data() as Map<String, dynamic>;
              String senderId = requests[index].id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    request['senderImageUrl'] ?? 'https://example.com/default-avatar.png',
                  ),
                ),
                title: Text(request['senderName'] ?? 'Unknown'),
                subtitle: Text("Sent you a friend request"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _acceptRequest(senderId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Accept", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _rejectRequest(senderId),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Reject",style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
