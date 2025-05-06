import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'update_password_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool isForgotPassword; 
  const ChangePasswordScreen({super.key, this.isForgotPassword = true});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  bool isOtpSent = false;

  void _sendOtp() {
    if (emailController.text.isNotEmpty) {
      setState(() {
        isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent to your email!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email!")),
      );
    }
  }

  void _verifyOtp() {
    if (otpController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UpdatePasswordScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          widget.isForgotPassword ? "Forgot Password" : "Change Password",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BounceInDown(
                duration: const Duration(milliseconds: 1200),
                child: const Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(height: 20),
              FadeIn(
                duration: const Duration(milliseconds: 1500),
                child: Text(
                  widget.isForgotPassword ? "Forgot Password?" : "Change Password",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              FadeIn(
                duration: const Duration(milliseconds: 1800),
                child: Text(
                  widget.isForgotPassword
                      ? "Enter your email address to receive an OTP."
                      : "Enter your email address to change your password.",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              SlideInUp(
                duration: const Duration(milliseconds: 1000),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
              if (isOtpSent) ...[
                const SizedBox(height: 20),
                SlideInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: TextFormField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3B82F6)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _sendOtp,
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(color: Color(0xFF3B82F6)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SlideInUp(
                duration: const Duration(milliseconds: 1200),
                child: ElevatedButton(
                  onPressed: isOtpSent ? _verifyOtp : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    isOtpSent ? "Verify OTP" : "Send OTP",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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