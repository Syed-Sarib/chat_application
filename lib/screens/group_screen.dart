import 'package:flutter/material.dart';

class GroupScreen extends StatefulWidget {
  GroupScreen({super.key});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final List<Map<String, String>> groups = [
    {
      "name": "Family Group",
      "message": "Let's plan the next vacation.",
      "time": "10:30 AM",
    },
    {
      "name": "Work Team",
      "message": "Meeting at 3 PM today.",
      "time": "9:15 AM",
    },
    {
      "name": "Friends Hangout",
      "message": "Barbecue this weekend!",
      "time": "Yesterday",
    },
    {
      "name": "Study Group",
      "message": "Don't forget the project deadline!",
      "time": "Monday",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Groups"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10),
        itemCount: groups.length,
        separatorBuilder: (_, __) => Divider(indent: 80),
        itemBuilder: (context, index) {
          final group = groups[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.group, color: Colors.blueAccent, size: 28),
            ),
            title: Text(
              group["name"]!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(group["message"]!),
            trailing: Text(
              group["time"]!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            onTap: () {
              // Navigate to the group chat screen when a group is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChatScreen(groupName: group["name"]!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  final String groupName;

  GroupChatScreen({required this.groupName});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Messages from various friends (Ali, Ahmad, Mehdi, Turab)
  final List<Map<String, String>> messages = [
    {"sender": "Ali", "message": "Hey everyone, ready for the meetup?", "time": "10:00 AM"},
    {"sender": "Me", "message": "Yes, all set!", "time": "10:01 AM"},
    {"sender": "Ahmad", "message": "I'm in, can't wait!", "time": "10:05 AM"},
    {"sender": "Me", "message": "See you all there!", "time": "10:10 AM"},
    {"sender": "Mehdi", "message": "Is the barbecue still on?", "time": "10:15 AM"},
    {"sender": "Turab", "message": "Absolutely, bring your appetite!", "time": "10:20 AM"},
  ];

  final Map<String, Color> senderColors = {
    "Ali": Colors.blue, // Blue for your messages
    "Ahmad": Colors.greenAccent,
    "Mehdi": Colors.orangeAccent,
    "Turab": Colors.purpleAccent,
    "Me": Colors.blue, // Blue for your messages
  };

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({
          "sender": "Me",
          "message": _controller.text,
          "time": "Just Now",
        });
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isMe = message["sender"] == "Me";
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: senderColors[message["sender"]] ?? Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sender name with @
                              Text(
                                '@${message["sender"]}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              // Message Text
                              Text(
                                message["message"]!,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              // Message time
                              Text(
                                message["time"]!,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: false, // No fill color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GroupScreen(),
  ));
}
