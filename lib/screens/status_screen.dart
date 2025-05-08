import 'package:flutter/material.dart';
import 'add_status_screen.dart';

class StatusScreen extends StatelessWidget {
  final List<Map<String, String>> friendStatuses = [
    {
      "name": "Ali",
      "time": "Today, 9:00 AM",
    },
    {
      "name": "Ahmad",
      "time": "Today, 7:45 AM",
    },
    {
      "name": "Turab",
      "time": "Yesterday, 6:15 PM",
    },
    {
      "name": "Mehdi",
      "time": "Yesterday, 10:30 AM",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // My status
          ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            title: Text("My Status", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Tap to add status update"),
            onTap: () async {
              final newStatus = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddStatusScreen()),
              );

              if (newStatus != null) {
                print("New Status: $newStatus");
              }
            },
          ),

          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Recent Updates",
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          Divider(thickness: 1),

          // Friends' statuses
          ...friendStatuses.map((status) {
            return ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blueGrey[200],
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(status["name"]!, style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(status["time"]!),
              onTap: () {
                // Handle viewing friend's status
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
