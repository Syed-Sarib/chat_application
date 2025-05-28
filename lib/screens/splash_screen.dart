import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'welcome_screen.dart';
import '../api/apis.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for the fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    try {
      await APIs.init();
      _fadeController.forward(); // Start the fade animation
      await Future.delayed(const Duration(seconds: 2));
      _navigateToNext();
    } catch (e) {
      print("Splash initialization error: $e");
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null ? const HomeScreen() : const WelcomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBEBEB), // Set background to #EBEBEB
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add the animated logo image here with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Image.asset(
                      'assets/images/default_avatar.jpeg', // Replace with your logo's path
                      width: 200, // Adjust the width as needed
                      height: 200, // Adjust the height as needed
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Powered By MS",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.6), // Light gray color
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}