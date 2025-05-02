import 'package:chat_application/screens/status_screen.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'group_screen.dart';

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
    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 700),
        curve: Curves.easeInOut);
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
        physics: BouncingScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 0, // Hide the text of unselected tabs
        showSelectedLabels: true,
        showUnselectedLabels: false, // Hide the text of unselected tabs
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: _selectedIndex == 0 ? 'Chats' : '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: _selectedIndex == 1 ? 'Groups' : '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: _selectedIndex == 2 ? 'Status' : '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: _selectedIndex == 3 ? 'Profile' : '',
          ),
        ],
      ),
    );
  }
}

