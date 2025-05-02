import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Add this package for animations
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated Icon
              BounceInDown(
                duration: Duration(milliseconds: 1200),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 100,
                  color: Color(0xFF3B82F6),
                ),
              ),
              SizedBox(height: 20),
              // Animated Welcome Text
              FadeIn(
                duration: Duration(milliseconds: 1500),
                child: Text(
                  "Welcome to Chat App",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              FadeIn(
                duration: Duration(milliseconds: 1800),
                child: Text(
                  "Connect with your friends and family\nanytime, anywhere!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),
              // Animated Login Button
              SlideInUp(
                duration: Duration(milliseconds: 1000),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login),
                      SizedBox(width: 8),
                      Text("Login"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Animated Sign Up Button
              SlideInUp(
                duration: Duration(milliseconds: 1200),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF3B82F6),
                    side: BorderSide(color: Color(0xFF3B82F6)),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add),
                      SizedBox(width: 8),
                      Text("Sign Up"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}