import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Add this package for animations
import 'dart:async';
import 'home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  Timer? _timer;
  int _secondsRemaining = 180;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _secondsRemaining = 180;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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

  void verifyOtp() {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter 6-digit OTP")));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: otpControllers[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("OTP Verification", style: TextStyle(color: Colors.white)),
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
                  Icons.sms_outlined,
                  size: 100,
                  color: Color(0xFF3B82F6),
                ),
              ),
              SizedBox(height: 20),
              // Animated Title
              FadeIn(
                duration: Duration(milliseconds: 1500),
                child: Text(
                  "Verify Your OTP",
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
                  "Enter the 6-digit OTP sent to your email",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),
              // OTP Input Fields
              SlideInUp(
                duration: Duration(milliseconds: 1000),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => buildOtpBox(index)),
                ),
              ),
              SizedBox(height: 16),
              // Timer
              FadeIn(
                duration: Duration(milliseconds: 1200),
                child: Text(
                  "Time left: $formattedTime",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              SizedBox(height: 24),
              // Verify Button
              SlideInUp(
                duration: Duration(milliseconds: 1400),
                child: ElevatedButton(
                  onPressed: verifyOtp,
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
                    "Verify",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Resend OTP Button
              FadeIn(
                duration: Duration(milliseconds: 1600),
                child: TextButton(
                  onPressed: _canResend
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("OTP Resent")),
                          );
                          startTimer();
                        }
                      : null,
                  child: Text(
                    "Resend OTP",
                    style: TextStyle(
                      color: _canResend ? Color(0xFF3B82F6) : Colors.grey,
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