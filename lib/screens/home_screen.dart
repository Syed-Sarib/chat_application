import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'group_screen.dart';
import 'status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ChatScreen(),
    GroupScreen(),
    StatusScreen(),
    ProfileScreen(),
  ];

  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
        physics:BouncingScrollPhysics(), // Disable swipe to switch pages
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60,
        backgroundColor: Colors.transparent, // Background color behind the navbar
        color: Colors.blueAccent, // Navbar color
        buttonBackgroundColor: Colors.transparent, // Floating button color
        animationDuration: Duration(milliseconds: 500),
        animationCurve: Curves.easeInOutCubicEmphasized,
        items: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded square shape
                  color: _selectedIndex == 0 ? Colors.blueAccent : Colors.transparent, // Highlight selected
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.chat,
                  size: 30,
                  color: _selectedIndex == 0 ? Colors.white : Colors.white,
                ),
              ),
              if (_selectedIndex != 0) // Show name only if not selected
                const Text(
                  "Chat",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded square shape
                  color: _selectedIndex == 1 ? Colors.blueAccent : Colors.transparent, // Highlight selected
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.group,
                  size: 30,
                  color: _selectedIndex == 1 ? Colors.white : Colors.white,
                ),
              ),
              if (_selectedIndex != 1) // Show name only if not selected
                const Text(
                  "Group",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded square shape
                  color: _selectedIndex == 2 ? Colors.blueAccent : Colors.transparent, // Highlight selected
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.circle,
                  size: 30,
                  color: _selectedIndex == 2 ? Colors.white : Colors.white,
                ),
              ),
              if (_selectedIndex != 2) // Show name only if not selected
                const Text(
                  "Status",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded square shape
                  color: _selectedIndex == 3 ? Colors.blueAccent : Colors.transparent, // Highlight selected
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: _selectedIndex == 3 ? Colors.white : Colors.white,
                ),
              ),
              if (_selectedIndex != 3) // Show name only if not selected
                const Text(
                  "Profile",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _onItemTapped(index);
        },
      ),
    );
  }
}