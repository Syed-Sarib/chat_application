import 'package:flutter/material.dart';
import 'conversation_screen.dart';
import 'friend_search_screen.dart';
import 'friend_request_screen.dart';
class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  bool _isSearchMode = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final List<Map<String, String>> chats = [
    {
      "name": "Ali",
      "message": "See you soon!",
      "time": "10:30 AM",
    },
    {
      "name": "Ahmad",
      "message": "Got it, thanks!",
      "time": "9:15 AM",
    },
    {
      "name": "Turab",
      "message": "Let's catch up later.",
      "time": "Yesterday",
    },
    {
      "name": "Mehdi",
      "message": "On my way!",
      "time": "Monday",
    },
    {
      "name": "Ali",
      "message": "See you soon!",
      "time": "10:30 AM",
    },
    {
      "name": "Ahmad",
      "message": "Got it, thanks!",
      "time": "9:15 AM",
    },
    {
      "name": "Turab",
      "message": "Let's catch up later.",
      "time": "Yesterday",
    },
    {
      "name": "Mehdi",
      "message": "On my way!",
      "time": "Monday",
    },
    {
      "name": "Ali",
      "message": "See you soon!",
      "time": "10:30 AM",
    },
    {
      "name": "Ahmad",
      "message": "Got it, thanks!",
      "time": "9:15 AM",
    },
    {
      "name": "Turab",
      "message": "Let's catch up later.",
      "time": "Yesterday",
    },
    {
      "name": "Mehdi",
      "message": "On my way!",
      "time": "Monday",
    },
    {
      "name": "Ali",
      "message": "See you soon!",
      "time": "10:30 AM",
    },
    {
      "name": "Ahmad",
      "message": "Got it, thanks!",
      "time": "9:15 AM",
    },
    {
      "name": "Turab",
      "message": "Let's catch up later.",
      "time": "Yesterday",
    },
    {
      "name": "Mehdi",
      "message": "On my way!",
      "time": "Monday",
    },
  ];

  DateTime? _lastPressedAt; // Track the time of the last back press

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

  // This method will handle the back button logic
  Future<bool> _onWillPop() async {
    if (_isSearchMode) {
      // If in search mode, exit search mode instead of navigating back
      setState(() {
        _isSearchMode = false;
        _searchController.clear();
        FocusScope.of(context).unfocus(); // Hide the keyboard
      });
      return false; // Prevent default back navigation
    }

    // If not in search mode, handle the double press logic to exit
    if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {
      // If it has been more than 2 seconds since the last press, show the message
      _lastPressedAt = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Press again to exit"),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Prevent default back navigation
    }

    // If pressed within 2 seconds, exit the app
    return true; // Allow app exit
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle the back button press
      child: Scaffold(
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
                                hintText: "Search Chats...",
                                border: InputBorder.none,
                              ),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text("Chats", key: ValueKey("title"), style: TextStyle(color: Colors.white)),
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
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add spacing around the box
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color of the box
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
                      backgroundColor: Colors.grey, // Default color as placeholder
                      child: Icon(Icons.person, color: Colors.white), // Default icon
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
                            imageUrl: '', // No imageUrl needed here
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
                Navigator.pop(context); // Close the bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchFriendScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt),
              title: Text('Friend Requests'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendRequestScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  },
),
      ),
    );
  }
}
