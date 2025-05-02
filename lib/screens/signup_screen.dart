import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Add this package for animations
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Sign Up",style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF3B82F6),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated Icon
              BounceInDown(
                duration: Duration(milliseconds: 1200),
                child: Icon(
                  Icons.person_add_alt_1_outlined,
                  size: 100,
                  color: Color(0xFF3B82F6),
                ),
              ),
              SizedBox(height: 20),
              // Animated Title
              FadeIn(
                duration: Duration(milliseconds: 1500),
                child: Text(
                  "Create Your Account",
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
                  "Sign up to get started with Chat App",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),
              // Username Field
              SlideInUp(
                duration: Duration(milliseconds: 1000),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Email Field
              SlideInUp(
                duration: Duration(milliseconds: 1200),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Password Field
              SlideInUp(
                duration: Duration(milliseconds: 1400),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF3B82F6)),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 24),
              // Sign Up Button
              SlideInUp(
                duration: Duration(milliseconds: 1600),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => OtpVerificationScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Already Have an Account
              FadeIn(
                duration: Duration(milliseconds: 1800),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to login screen
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Color(0xFF3B82F6)),
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