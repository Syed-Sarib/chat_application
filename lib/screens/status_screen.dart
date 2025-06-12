import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_status_screen.dart';
import 'view_status_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> with SingleTickerProviderStateMixin {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> friendStatusPreview = [];
  List<Map<String, dynamic>> myStatuses = [];

  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isLoading = true;
  StreamSubscription<QuerySnapshot>? _statusSubscription;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _listenToStatusChanges();
  }

  void _listenToStatusChanges() {
    _statusSubscription = FirebaseFirestore.instance
        .collection('statuses')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        _loadStatuses(snapshot);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadStatuses(QuerySnapshot snapshot) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      final friends = List<String>.from(userDoc['friends'] ?? []);

      Map<String, List<Map<String, dynamic>>> groupedStatuses = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'];

        if (userId == currentUserId || friends.contains(userId)) {
          groupedStatuses.putIfAbsent(userId, () => []);
          groupedStatuses[userId]!.add({
            ...data,
            'docId': doc.id,
            'time': _formatTimestamp(data['timestamp']),
          });
        }
      }

      List<Map<String, dynamic>> myStatusList = groupedStatuses[currentUserId] ?? [];

      List<Map<String, dynamic>> previewList = [];

      for (var entry in groupedStatuses.entries) {
        if (entry.key == currentUserId) continue;

        final statuses = entry.value;
        final latestStatus = statuses.first;

        final friendDoc = await FirebaseFirestore.instance.collection('users').doc(entry.key).get();
        final friendName = friendDoc['name'] ?? 'Unknown';

        previewList.add({
          "userId": entry.key,
          "name": friendName,
          "latestStatus": latestStatus,
          "allStatuses": statuses,
        });
      }

      if (mounted) {
        setState(() {
          myStatuses = myStatusList;
          friendStatusPreview = previewList;
        });
      }
    } catch (e) {
      print("Error loading statuses: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? "PM" : "AM";
    return "${date.day}/${date.month}/${date.year}, $hour:$minute $period";
  }

  void _onStatusDeleted(String statusId) {
    FirebaseFirestore.instance.collection('statuses').doc(statusId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        foregroundColor: Colors.white,
        
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ListView(
              children: [
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () async {
                      if (myStatuses.isEmpty) {
                        final newStatus = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddStatusScreen()),
                        );
                        if (newStatus != null) {
                          await _saveStatusToFirebase(newStatus);
                        }
                      } else {
                        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                        final RenderBox box = context.findRenderObject() as RenderBox;
                        final Offset position = box.localToGlobal(Offset.zero, ancestor: overlay);

                        final selected = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(position.dx + 80, position.dy + 80, 0, 0),
                          items: [
                            PopupMenuItem(
                              value: 'add',
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: Colors.blue),
                                  SizedBox(width: 10),
                                  Text("Add Status"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, color: Colors.green),
                                  SizedBox(width: 10),
                                  Text("View Status"),
                                ],
                              ),
                            ),
                          ],
                        );

                        if (selected == 'add') {
                          final newStatus = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddStatusScreen()),
                          );
                          if (newStatus != null) {
                            await _saveStatusToFirebase(newStatus);
                          }
                        } else if (selected == 'view') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewStatusScreen(
                                currentUserId: currentUserId,
                                statuses: myStatuses,
                                onStatusDeleted: (statusId) => _onStatusDeleted(statusId),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey[300],
                            child: myStatuses.isEmpty
                                ? Icon(Icons.person, size: 30, color: Colors.white)
                                : ClipOval(
                                    child: Image.network(
                                      myStatuses.first['mediaUrl'] ?? '',
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          if (myStatuses.isEmpty)
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
                      subtitle: Text(myStatuses.isEmpty
                          ? "Tap to add status update"
                          : "Uploaded at ${myStatuses.first['time']}"),
                    ),
                  ),
                ),
                if (friendStatusPreview.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Recent Updates", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  ),
                Divider(thickness: 1),
                ...friendStatusPreview.map((statusPreview) {
                  final latest = statusPreview['latestStatus'];

                  return FadeTransition(
                    opacity: _animation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blueGrey[200],
                            child: ClipOval(
                              child: Image.network(
                                latest['mediaUrl'] ?? '',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(statusPreview["name"], style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(latest["time"]),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewStatusScreen(
                                  currentUserId: currentUserId,
                                  statuses: statusPreview['allStatuses'],
                                  onStatusDeleted: (statusId) => _onStatusDeleted(statusId),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Future<void> _saveStatusToFirebase(Map<String, dynamic> status) async {
    try {
      final timestamp = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance.collection('statuses').add({
        'userId': currentUserId,
        'text': status['text'],
        'mediaUrl': status['mediaUrl'],
        'mediaType': status['mediaType'],
        'timestamp': timestamp,
      });
    } catch (e) {
      print("Error saving status: $e");
    }
  }
}