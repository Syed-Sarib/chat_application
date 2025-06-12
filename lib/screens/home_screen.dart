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
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
      
    });
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
        physics: const BouncingScrollPhysics(),
        children: _screens, // Disable swipe to switch pages
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 70, // Increased height of the navigation bar
        backgroundColor: Colors.transparent, // Background color behind the navbar
        color: Colors.blueAccent, // Navbar color
        buttonBackgroundColor: Colors.transparent, // Floating button color
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        items: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8), // Add space above the icon
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded square shape
                  color: _selectedIndex == 0 ? Colors.blueAccent : Colors.transparent, // Highlight selected
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.chat,
                  size: 30,
                  color: _selectedIndex == 0 ? Colors.white : Colors.white,
                ),
              ),
              if (_selectedIndex != 0) // Show name only if not selected
                const Text(
                  "Chat",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8), // Add space above the icon
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded square shape
                  color: _selectedIndex == 1 ? Colors.blueAccent : Colors.transparent, // Highlight selected
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.group,
                  size: 30,
                  color: _selectedIndex == 1 ? Colors.white : Colors.white,
                ),
              ),
              if (_selectedIndex != 1) // Show name only if not selected
                const Text(
                  "Group",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8), // Add space above the icon
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded square shape
                  color: _selectedIndex == 2 ? Colors.blueAccent : Colors.transparent, // Highlight selected
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.circle,
                  size: 30,
                  color: _selectedIndex == 2 ? Colors.white : Colors.white,
                ),
              ),
              if (_selectedIndex != 2) // Show name only if not selected
                const Text(
                  "Status",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8), // Add space above the icon
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded square shape
                  color: _selectedIndex == 3 ? Colors.blueAccent : Colors.transparent, // Highlight selected
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: _selectedIndex == 3 ? Colors.white : Colors.white,
                ),
              ),
              if (_selectedIndex != 3) // Show name only if not selected
                const Text(
                  "Profile",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
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