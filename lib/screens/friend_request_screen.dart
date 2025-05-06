import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  final List<Map<String, dynamic>> _friendRequests = [
    {"name": "Ali", "time": DateTime.now().subtract(Duration(hours: 1))},
    {"name": "Ahmad", "time": DateTime.now().subtract(Duration(days: 1))},
    {"name": "Sarah", "time": DateTime.now().subtract(Duration(days: 2))},
    {"name": "Ayesha", "time": DateTime.now().subtract(Duration(days: 3))},
  ];

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return DateFormat('MMM d, yyyy').format(time); // e.g., "Jan 1, 2025"
    }
  }

  void _acceptRequest(int index) {
    setState(() {
      _friendRequests.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Friend request accepted!")),
    );
  }

  void _rejectRequest(int index) {
    setState(() {
      _friendRequests.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Friend request rejected!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      body: _friendRequests.isEmpty
          ? const Center(
              child: Text(
                "No friend requests.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _friendRequests.length,
              itemBuilder: (context, index) {
                final request = _friendRequests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        request["name"][0], // First letter of the name
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(request["name"]),
                    subtitle: Text("Requested: ${_formatTime(request["time"])}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Accept Button
                        ElevatedButton(
                          onPressed: () => _acceptRequest(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text("Accept", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        // Reject Button
                        ElevatedButton(
                          onPressed: () => _rejectRequest(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text("Reject", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}