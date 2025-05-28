import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 100, color: Colors.redAccent),
            SizedBox(height: 20),
            Text("No Internet Connection", style: TextStyle(fontSize: 22, color: Colors.red)),
            SizedBox(height: 10),
            Text("Please check your connection and try again."),
          ],
        ),
      ),
    );
  }
}
