import 'package:flutter/material.dart';

class SearchFriendScreen extends StatefulWidget {
  const SearchFriendScreen({super.key});

  @override
  State<SearchFriendScreen> createState() => _SearchFriendScreenState();
}

class _SearchFriendScreenState extends State<SearchFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _friends = [
    "Ali",
    "Ahmad",
    "Turab",
    "Mehdi",
    "Sarah",
    "Ayesha",
    "Zain",
    "Hassan",
  ]; // Example friend list
  List<String> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _filteredFriends = _friends; // Initially show all friends
  }

  void _filterFriends(String query) {
    setState(() {
      _filteredFriends = _friends
          .where((friend) => friend.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Friend",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _filterFriends,
              decoration: InputDecoration(
                hintText: "Search for a friend...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Friend List
            Expanded(
              child: _filteredFriends.isEmpty
                  ? const Center(
                      child: Text(
                        "No friends found.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredFriends.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              _filteredFriends[index][0], // First letter of the name
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(_filteredFriends[index]),
                          onTap: () {
                            // Handle friend selection
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "You selected ${_filteredFriends[index]}"),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}