import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendInfoScreen extends StatefulWidget {
  final String friendId;
  final String friendName;
  final String friendImageUrl;

  const FriendInfoScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.friendImageUrl,
  });

  @override
  State<FriendInfoScreen> createState() => _FriendInfoScreenState();
}

class _FriendInfoScreenState extends State<FriendInfoScreen> {
  bool _requestSent = false;
  bool _isFriend = false;

  @override
  void initState() {
    super.initState();
    _checkFriendStatus();
  }

  Future<void> _checkFriendStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid == widget.friendId) {
      setState(() {
        _requestSent = true;
      });
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    final data = userDoc.data();
    if (data != null && data['friends'] != null) {
      final List<dynamic> friends = data['friends'];
      if (friends.contains(widget.friendId)) {
        setState(() {
          _isFriend = true;
        });
        return;
      }
    }

    final requestDoc = await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(widget.friendId)
        .collection('requests')
        .doc(currentUser.uid)
        .get();

    if (requestDoc.exists) {
      setState(() {
        _requestSent = true;
      });
    }
  }

  Future<void> _sendFriendRequest(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid == widget.friendId) return;

    try {
      final senderSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

      if (!senderSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your profile was not found.")),
        );
        return;
      }

      final senderData = senderSnapshot.data() as Map<String, dynamic>;

      final requestRef = FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(widget.friendId)
          .collection('requests')
          .doc(currentUser.uid);

      await requestRef.set({
        'senderId': currentUser.uid,
        'senderName': senderData['name'],
        'senderImageUrl': senderData['profileImageUrl'],
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      setState(() {
        _requestSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Friend request sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.friendId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("Friend not found"));
        }

        final friendData = userSnapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.friendName, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.blueAccent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      widget.friendImageUrl.isNotEmpty
                          ? widget.friendImageUrl
                          : 'https://example.com/default-avatar.png',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.friendName,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    friendData['email'],
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  if (currentUser != null &&
                      currentUser.uid != widget.friendId &&
                      !_requestSent &&
                      !_isFriend)
                    ElevatedButton.icon(
                      onPressed: () => _sendFriendRequest(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text("Send"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  if (_requestSent)
                    const Text(
                      "Request already sent",
                      style: TextStyle(color: Colors.grey),
                    ),

                  // if (_isFriend)
                  //   const Text(
                  //     "Already your friend",
                  //     style: TextStyle(color: Colors.green),
                  //   ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
