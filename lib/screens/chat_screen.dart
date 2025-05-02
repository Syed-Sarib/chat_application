import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final List<Map<String, String>> chats = [
    {
      "name": "Ali",
      "message": "See you soon!",
      "time": "10:30 AM",
      "imageUrl": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Ahmad",
      "message": "Got it, thanks!",
      "time": "9:15 AM",
      "imageUrl": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Turab",
      "message": "Let's catch up later.",
      "time": "Yesterday",
      "imageUrl": "https://i.pravatar.cc/150?img=3",
    },
    {
      "name": "Mehdi",
      "message": "On my way!",
      "time": "Monday",
      "imageUrl": "https://i.pravatar.cc/150?img=4",
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
        foregroundColor: Colors.white,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    name: chat["name"]!,
                    imageUrl: chat["imageUrl"]!,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.person_add, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.search),
                    title: Text('Search Friend'),
                    onTap: () {
                      Navigator.pop(context);
                      // Handle Search Friend
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person_add_alt),
                    title: Text('Friend Requests'),
                    onTap: () {
                      Navigator.pop(context);
                      // Handle Friend Requests
                    },
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

class ConversationScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  const ConversationScreen({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [
    {"sender": "Ali", "message": "Hi, how are you?", "time": "10:00 AM"},
    {"sender": "Me", "message": "I'm good, you?", "time": "10:01 AM"},
    {"sender": "Ali", "message": "All set for today?", "time": "10:02 AM"},
  ];

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

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('Add Document'),
              onTap: () {
                Navigator.pop(context);
                // Handle Add Document
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Add Image'),
              onTap: () {
                Navigator.pop(context);
                // Handle Add Image
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl),
              radius: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.name,
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: Icon(Icons.call, color: Colors.white),
              onPressed: () {},
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {},
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(value: 'info', child: Text('Friend Info')),
                PopupMenuItem(value: 'remove', child: Text('Remove Friend')),
              ],
            ),
          ],
        ),
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
                            color: isMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message["message"]!,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                message["time"]!,
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white70
                                      : Colors.black54,
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
                IconButton(
                  icon: Icon(Icons.add, color: Colors.grey[700]),
                  onPressed: _showAddOptions,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: true,
                      fillColor: Colors.grey[200],
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
