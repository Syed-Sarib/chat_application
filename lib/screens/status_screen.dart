import 'package:flutter/material.dart';
import 'add_status_screen.dart';

class StatusScreen extends StatefulWidget {
  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  String? myStatus; // Variable to store the user's status
  String? statusTime; // Variable to store the time of the status upload

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
                if (myStatus == null)
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
            subtitle: Text(myStatus == null
                ? "Tap to add status update"
                : "Uploaded at $statusTime"),
            onTap: () async {
              if (myStatus == null) {
                final newStatus = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddStatusScreen()),
                );

                if (newStatus != null) {
                  setState(() {
                    myStatus = newStatus; // Update the status
                    statusTime = _getCurrentTime(); // Save the current time
                  });
                }
              } else {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return FadeTransition(
                        opacity: animation,
                        child: Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.blueAccent, width: 2), // Blue outline
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Your Status",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.grey),
                                      onPressed: () {
                                        Navigator.pop(context); // Close the dialog
                                      },
                                    ),
                                  ],
                                ),
                                Divider(thickness: 1, color: Colors.grey[300]),
                                SizedBox(height: 16),
                                Text(
                                  myStatus!,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Uploaded at $statusTime",
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      myStatus = null; // Remove the status
                                      statusTime = null; // Clear the time
                                    });
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  label: Text("Remove Status",style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0); // Start from the bottom
                      const end = Offset.zero; // End at the center
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Card background color
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3), // Shadow color
                      spreadRadius: 1, // Spread radius
                      blurRadius: 5, // Blur radius
                      offset: Offset(0, 3), // Shadow position
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blueGrey[200],
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    status["name"]!,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(status["time"]!),
                  onTap: () {
                    // Handle viewing friend's status
                  },
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? "PM" : "AM";
    return "${now.day}/${now.month}/${now.year}, $hour:$minute $period";
  }
}
