import 'package:flutter/material.dart';

class FriendInfoScreen extends StatelessWidget {
  final String friendName;
  final String friendImageUrl;

  const FriendInfoScreen({
    super.key,
    required this.friendName,
    required this.friendImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Info"),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          // Blue background
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.blueAccent,
          ),

          // Card and avatar
          Column(
            children: [
              const SizedBox(height: 90), 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50), // Space for the avatar inside the card
                        Center(
                          child: Text(
                            "@$friendName",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            "Friend's Profile Information",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _infoRow("Email", "friend@example.com"),
                        _infoRow("Join Date", "2025-01-01"),
                        _infoRow("Status", "Active"),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Navigate back to the previous screen
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                            ),
                            child: const Text(
                              "Back",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Avatar overlapping the card
          Positioned(
            top: 30, // Adjust this value to control overlap
            left: MediaQuery.of(context).size.width / 2 - 50, // Center the avatar
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(friendImageUrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}