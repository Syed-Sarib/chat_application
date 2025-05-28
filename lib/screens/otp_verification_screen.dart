import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login_screen.dart'; // Update as needed
import 'home_screen.dart'; // Your home screen after successful login
import '../services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final bool isLogin; // Flag to differentiate login or signup

  const OtpVerificationScreen({
    super.key,
    required this.username,
    required this.email,
    required this.password,
    required this.isLogin,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _isLoading = false; // Added loading state for better UX

  @override
  void initState() {
    super.initState();
    _sendOtp();
    startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodes[0]);
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });

    bool sent = await AuthService.sendOtpToEmail(widget.email);
    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send OTP. Please try again.")),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void startTimer() {
    _secondsRemaining = 180;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      bool isValid = await AuthService.verifyOtp(widget.email, otp);
      if (isValid) {
        if (widget.isLogin) {
          bool success = await AuthService.loginUser(widget.email, widget.password);
          if (success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login failed. Please try again.")),
            );
          }
        } else {
          String? pushToken = await FirebaseMessaging.instance.getToken();
          if (pushToken != null) {
            await AuthService.registerUser(widget.username, widget.email, widget.password, pushToken);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP. Please try again.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter 6-digit OTP")),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Widget buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          } else if (index == 5 && value.isNotEmpty) {
            verifyOtp(); // Auto-submit
          }
        },
      ),
    );
  }

  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(focusNodes[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("OTP Verification", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BounceInDown(
                duration: const Duration(milliseconds: 1200),
                child: const Icon(Icons.sms_outlined, size: 100, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(height: 20),
              FadeIn(
                duration: const Duration(milliseconds: 1500),
                child: const Text(
                  "Verify Your OTP",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              FadeIn(
                duration: const Duration(milliseconds: 1800),
                child: const Text(
                  "Enter the 6-digit OTP sent to your email",
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              SlideInUp(
                duration: const Duration(milliseconds: 1000),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => buildOtpBox(index)),
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                duration: const Duration(milliseconds: 1200),
                child: Text(
                  "Time left: $formattedTime",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              SlideInUp(
                duration: const Duration(milliseconds: 1400),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : verifyOtp, // Disable button if loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Verify", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              FadeIn(
                duration: const Duration(milliseconds: 1600),
                child: TextButton(
                  onPressed: _canResend
                      ? () async {
                          await _sendOtp();
                          startTimer();
                          clearOtpFields();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("OTP Resent")),
                          );
                        }
                      : null,
                  child: Text(
                    "Resend OTP",
                    style: TextStyle(
                      color: _canResend ? const Color(0xFF3B82F6) : Colors.grey,
                    ),
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
