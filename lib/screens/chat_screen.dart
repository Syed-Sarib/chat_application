import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final List<Map<String, String>> chats = [
    {
      "name": "Alice",
      "message": "See you soon!",
      "time": "10:30 AM",
      "imageUrl": "https://i.pravatar.cc/150?img=3",
    },
    {
      "name": "Bob",
      "message": "Got it, thanks!",
      "time": "9:15 AM",
      "imageUrl": "https://i.pravatar.cc/150?img=5",
    },
    {
      "name": "Charlie",
      "message": "Let's catch up later.",
      "time": "Yesterday",
      "imageUrl": "https://i.pravatar.cc/150?img=6",
    },
  ];

   ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10),
        itemCount: chats.length,
        separatorBuilder: (_, __) => Divider(indent: 80),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(chat["imageUrl"]!),
            ),
            title: Text(
              chat["name"]!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(chat["message"]!),
            trailing: Text(
              chat["time"]!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            onTap: () {
              // Navigate to message screen if needed
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Padding(
              padding: EdgeInsets.all(20),
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Add Friend'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to add friend page
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person_search),
                    title: Text('Friend Requests'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to friend request page
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
