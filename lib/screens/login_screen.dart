import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; 
import 'otp_verification_screen.dart';
import 'change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Login",style: TextStyle(color: Colors.white)),
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
                  Icons.lock_outline,
                  size: 100,
                  color: Color(0xFF3B82F6),
                ),
              ),
              SizedBox(height: 20),
              // Animated Title
              FadeIn(
                duration: Duration(milliseconds: 1500),
                child: Text(
                  "Welcome Back!",
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
                  "Login to your account to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),
              // Email Field
              SlideInUp(
                duration: Duration(milliseconds: 1000),
                child: TextFormField(
                  controller: emailController,
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
                duration: Duration(milliseconds: 1200),
                child: TextFormField(
                  controller: passwordController,
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
              // Login Button
              SlideInUp(
                duration: Duration(milliseconds: 1400),
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
                    "Login",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Forgot Password
              FadeIn(
                duration: Duration(milliseconds: 1600),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(isForgotPassword: true),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
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