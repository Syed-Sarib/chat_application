import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddStatusScreen extends StatefulWidget {
  @override
  _AddStatusScreenState createState() => _AddStatusScreenState();
}

class _AddStatusScreenState extends State<AddStatusScreen> {
  final TextEditingController _statusController = TextEditingController();
  String? _selectedFilePath; // To store the selected file path
  String? _fileType; // To store the type of the selected file (image/video)

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  void _submitStatus() {
    final statusText = _statusController.text.trim();
    if (statusText.isNotEmpty || _selectedFilePath != null) {
      Navigator.pop(context, {
        "text": statusText,
        "filePath": _selectedFilePath,
        "fileType": _fileType,
      }); // Return the status text and file to the previous screen
      _statusController.clear(); // Clear the text field
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a status or select a file before submitting.")),
      );
    }
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result;
    if (type == "image") {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
    } else if (type == "video") {
      result = await FilePicker.platform.pickFiles(type: FileType.video);
    }

    if (result?.files.isNotEmpty ?? false) { // Add null check for `result`
      setState(() {
        _selectedFilePath = result!.files.single.path; // Use `!` to assert non-null
        _fileType = type;
      });
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
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickFile("image"),
                  icon: Icon(Icons.image, color: Colors.white),
                  label: Text("Add Image",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _pickFile("video"),
                  icon: Icon(Icons.videocam, color: Colors.white),
                  label: Text("Add Video",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedFilePath != null) ...[
              SizedBox(height: 16),
              Text(
                "Selected file: ${_selectedFilePath!.split('/').last}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _submitStatus,
              icon: Icon(Icons.send, color: Colors.white), // Set icon color to white
              label: Text(
                "Post Status",
                style: TextStyle(color: Colors.white),
              ),
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