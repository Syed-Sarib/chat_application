import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  // Handle Forgot Password
  Future<void> handlePasswordReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showSnackBar('Please enter your email');
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showSnackBar('Password reset email sent!');
      Navigator.pop(context); // Go back to the login screen
    } catch (e) {
      showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Show SnackBar
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,  // Ensures screen adjusts when keyboard appears
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Forgot Password", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              BounceInDown(
                duration: const Duration(milliseconds: 1200),
                child: const Icon(Icons.lock_outline, size: 100, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(height: 20),
              FadeIn(
                duration: const Duration(milliseconds: 1500),
                child: const Text("Forgot Password?",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              ),
              const SizedBox(height: 40),
              SlideInUp(
                duration: const Duration(milliseconds: 1000),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter your Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SlideInUp(
                duration: const Duration(milliseconds: 1400),
                child: ElevatedButton(
                  onPressed: isLoading ? null : handlePasswordReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send Reset Link", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
