import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'conversation_screen.dart';
import 'friend_search_screen.dart';
import 'friend_request_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  bool _isSearchMode = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  DateTime? _lastPressedAt;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String currentUserId;
  String _searchText = '';

  late Future<List<Map<String, dynamic>>> _chatUsersFuture;

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
    currentUserId = _auth.currentUser!.uid;
    _searchController.addListener(_onSearchChanged);
    _chatUsersFuture = _getChatUsers();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _triggerSearchMode() async {
    setState(() {
      _isSearchMode = true;
    });
    _fadeController.forward(from: 0);
  }

  Future<bool> _onWillPop() async {
    if (_isSearchMode) {
      setState(() {
        _isSearchMode = false;
        _searchController.clear();
        FocusScope.of(context).unfocus();
      });
      return false;
    }

    if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {
      _lastPressedAt = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Press again to exit"),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    return true;
  }

  String getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  Future<List<Map<String, dynamic>>> _getChatUsers() async {
    final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
    final currentUserData = currentUserDoc.data();
    final List<dynamic> friends = currentUserData?['friends'] ?? [];

    Set<String> userIds = Set<String>.from(friends);

    final chatDocs = await _firestore.collection('chats').get();
    for (var doc in chatDocs.docs) {
      if (doc.id.contains(currentUserId)) {
        final ids = doc.id.split('_');
        for (var id in ids) {
          if (id != currentUserId) {
            userIds.add(id);
          }
        }
      }
    }

    List<Map<String, dynamic>> users = [];

    for (var userId in userIds) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final chatId = getChatId(currentUserId, userId);
        final messagesSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        String lastMessage = 'No conversation yet';
        String lastTime = 'N/A';

        if (messagesSnapshot.docs.isNotEmpty) {
          final messageData = messagesSnapshot.docs.first.data();
          final type = messageData['type'] ?? 'text';

          // Handle text, image, video, audio, etc.
          switch (type) {
            case 'text':
              lastMessage = messageData['message'] ?? 'Text message';
              break;
            case 'image':
              lastMessage = '📷 Photo';
              break;
            case 'video':
              lastMessage = '🎥 Video';
              break;
            case 'audio':
              lastMessage = '🎵 Audio';
              break;
            case 'file':
              lastMessage = '📄 File';
              break;
            default:
              lastMessage = 'Message';
          }

          final timestamp = messageData['timestamp'] as Timestamp?;
          if (timestamp != null) {
            final dateTime = timestamp.toDate();
            lastTime = TimeOfDay.fromDateTime(dateTime).format(context);
          }
        }

        users.add({
          'id': userId,
          'name': userData['name'] ?? 'Unknown',
          'image': userData['image'] ?? '',
          'lastMessage': lastMessage,
          'lastTime': lastTime,
        });
      }
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          automaticallyImplyLeading: false,
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
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _isSearchMode = false;
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
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
                : Text("Chats", key: ValueKey("title"), style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
          ),
          centerTitle: true,
          actions: [
            if (!_isSearchMode)
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: _triggerSearchMode,
              ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _chatUsersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No chats available"));
            }
            final users = snapshot.data!
                .where((user) => user['name'].toLowerCase().contains(_searchText))
                .toList();

            if (users.isEmpty) {
              return Center(child: Text("No records found"));
            }

            return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.blueAccent,
              onRefresh: () async => setState(() {
                _chatUsersFuture = _getChatUsers();
              }),
              notificationPredicate: (_) => !_isSearchMode,
              child: ListView.builder(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 10),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey,
                          backgroundImage: user['image'] != ''
                              ? NetworkImage(user['image'])
                              : null,
                          child: user['image'] == ''
                              ? Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          user['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          user['lastMessage'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        trailing: Text(
                          user['lastTime'],
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          final chatId = getChatId(currentUserId, user['id']);
                          final friendId = user['id'];
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => ConversationScreen(
                                chatId: chatId,
                                userId: friendId,
                              ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0); // Start from the bottom of the screen
                                const end = Offset.zero; // End at the current position
                                const curve = Curves.easeInOutCubicEmphasized;

                                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                final offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          ).then((result) {
                            if (result == true) {
                              // Refresh the chat list by calling setState
                              setState(() {
                                _chatUsersFuture = _getChatUsers();
                              });
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchFriendScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.request_page),
                      title: Text('Friend Requests'),
                      onTap: () {
                        Navigator.pop(context);
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