import 'package:flutter/material.dart';

class AddStatusScreen extends StatefulWidget {
  @override
  _AddStatusScreenState createState() => _AddStatusScreenState();
}

class _AddStatusScreenState extends State<AddStatusScreen> {
  final TextEditingController _statusController = TextEditingController();

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  void _submitStatus() {
    final statusText = _statusController.text.trim();
    if (statusText.isNotEmpty) {
      
      Navigator.pop(context, statusText); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a status before submitting.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Status", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What's on your mind?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _statusController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Type your status here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _submitStatus,
              icon: Icon(Icons.send),
              label: Text("Post Status",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                textStyle: TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}