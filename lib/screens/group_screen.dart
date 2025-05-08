import 'package:flutter/material.dart';
import 'create_group_screen.dart';
import 'group_conversation_screen.dart';

class GroupScreen extends StatefulWidget {
  GroupScreen({super.key});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> with SingleTickerProviderStateMixin {
  bool _isSearchMode = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> groups = [
    {
      "name": "Family Group",
      "message": "Let's plan the next vacation.",
      "time": "10:30 AM",
      "participants": [
        {"name": "Alice", "imageUrl": "https://via.placeholder.com/150"},
        {"name": "Bob", "imageUrl": "https://via.placeholder.com/150"},
      ],
      "messages": [
        {"sender": "Alice", "message": "Hi everyone!", "time": "10:00 AM"},
        {"sender": "Bob", "message": "Let's plan the next vacation.", "time": "10:30 AM"},
      ],
    },
    {
      "name": "Work Team",
      "message": "Meeting at 3 PM today.",
      "time": "9:15 AM",
      "participants": [
        {"name": "John", "imageUrl": "https://via.placeholder.com/150"},
        {"name": "Doe", "imageUrl": "https://via.placeholder.com/150"},
      ],
      "messages": [
        {"sender": "John", "message": "Meeting at 3 PM today.", "time": "9:15 AM"},
      ],
    },
    {
      "name": "Friends Hangout",
      "message": "Barbecue this weekend!",
      "time": "Yesterday",
      "participants": [
        {"name": "Charlie", "imageUrl": "https://via.placeholder.com/150"},
        {"name": "David", "imageUrl": "https://via.placeholder.com/150"},
      ],
      "messages": [
        {"sender": "Charlie", "message": "Barbecue this weekend!", "time": "Yesterday"},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _triggerSearchMode() async {
    setState(() {
      _isSearchMode = true;
    });
    _fadeController.forward(from: 0); // Animate search bar appearance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes the default back button
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: _isSearchMode
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    key: ValueKey("search"),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              _isSearchMode = false; // Exit search mode
                              _searchController.clear(); // Clear the search input
                              FocusScope.of(context).unfocus(); // Hide the keyboard
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Search Groups...",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Text("Groups", key: ValueKey("title"), style: TextStyle(color: Colors.white)),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.blueAccent,
        onRefresh: _triggerSearchMode,
        notificationPredicate: (_) => !_isSearchMode,
        child: ListView.builder(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Padding(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupConversationScreen(
                          groupName: group["name"]!,
                          groupImageUrl: "https://via.placeholder.com/150",
                          participants: group["participants"],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateGroupScreen(
                onGroupCreated: (newGroup) {
                  setState(() {
                    groups.insert(0, newGroup); // Add the new group to the top of the list
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}