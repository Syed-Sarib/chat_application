import 'package:flutter/material.dart';
// TODO: Import Firebase Firestore for sending messages

class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();

  void _sendMessage() async {
    final enteredText = _controller.text;
    if (enteredText.trim().isEmpty) return;

    // TODO: Send message to Firebase Firestore here
    /*
    await FirebaseFirestore.instance.collection('chat').add({
      'text': enteredText,
      'createdAt': Timestamp.now(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
    */

    _controller.clear(); // clear input
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Send a message..."),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
