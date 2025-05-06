import 'package:flutter/material.dart';

class GetPremiumScreen extends StatelessWidget {
  const GetPremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Get Premium"),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Premium Icon
            const Icon(
              Icons.workspace_premium_rounded,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              "Unlock Premium Features",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Enjoy exclusive features with our premium plan.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Features List
            Expanded(
              child: ListView(
                children: [
                  _buildFeatureButton(Icons.backup, "Chat Backup"),
                  _buildFeatureButton(Icons.color_lens, "Change Theme"),
                  _buildFeatureButton(Icons.devices, "Multiple Device Login"),
                  _buildFeatureButton(Icons.translate, "AI Translator"),
                  _buildFeatureButton(Icons.location_on, "Nearby Friends Search"),
                ],
              ),
            ),

            // Subscribe Button
            ElevatedButton(
              onPressed: () {
                // Add subscription logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Subscription feature coming soon!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Subscribe Now",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          // Add feature-specific logic here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, color: Colors.blue),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}