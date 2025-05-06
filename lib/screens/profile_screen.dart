import 'dart:ui';
import 'package:flutter/material.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'chat_backup_screen.dart';
import 'edit_profile_screen.dart';
import 'dart:io';
import 'get_premium_screen.dart';

enum AppTheme { deviceDefault, light, dark, custom }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  AppTheme _selectedTheme = AppTheme.deviceDefault;
  String _profileName = "Sarib";
  String _profileDescription = "Frontend Developer";
  File? _profileAvatar;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  double get _headerAnimationProgress {
    return (_scrollOffset / 150).clamp(0.0, 1.0); // Adjust this for scroll effect
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = lerpDouble(100, 36, _headerAnimationProgress)!;
    final topPadding = lerpDouble(40, 12, _headerAnimationProgress)!;
    final leftPadding = lerpDouble(MediaQuery.of(context).size.width / 2 - 50, 16, _headerAnimationProgress)!;
    final nameFontSize = lerpDouble(24, 16, _headerAnimationProgress)!;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 20,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blue,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Opacity(
                    opacity: _headerAnimationProgress,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: imageSize / 2,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: imageSize / 2 - 4,
                            backgroundImage: _profileAvatar != null
                                ? FileImage(_profileAvatar!)
                                : const AssetImage("assets/images/default_avatar.png") as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _profileName,
                          style: TextStyle(fontSize: nameFontSize, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  background: Container(),
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                Stack(
                  children: [
                    // Blue background at top
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.blue,
                    ),

                    // White card below avatar
                    Container(
                      padding: const EdgeInsets.only(top: 120),
                      alignment: Alignment.topCenter,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                          child: Column(
                            children: [
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: 1 - _headerAnimationProgress,
                                child: Column(
                                  children: [
                                    Text("@$_profileName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(_profileDescription, style: TextStyle(color: Colors.grey[700])),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                              infoRow("Email", "233505@students.au.edu.pk"),
                              infoRow("Join Date", "2025-01-01"),
                              infoRow("User Tier", "Premium"),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        currentName: _profileName, // Pass the current name
                                        currentDescription: _profileDescription, // Pass the current description
                                      ),
                                    ),
                                  );

                                  if (result != null && result is Map<String, dynamic>) {
                                    setState(() {
                                      // Update the profile information
                                      _profileName = result['name'];
                                      _profileDescription = result['description'];
                                      _profileAvatar = result['avatar'];
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Profile updated successfully!")),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit Profile"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Avatar positioned on blue background
                    Positioned(
                      top: topPadding,
                      left: leftPadding,
                      child: AnimatedOpacity(
                        opacity: 1 - _headerAnimationProgress,
                        duration: const Duration(milliseconds: 200),
                        child: CircleAvatar(
                          radius: imageSize / 2,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: imageSize / 2 - 4,
                            backgroundImage: _profileAvatar != null
                                ? FileImage(_profileAvatar!)
                                : const AssetImage("assets/images/default_avatar.png") as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutConfirmationDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Settings Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 8),

                // Settings Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock, color: Colors.blue),
                          title: const Text("Change Password"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePasswordScreen(isForgotPassword: false),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.color_lens, color: Colors.blue),
                          title: const Text("Change Theme"),
                          onTap: () {
                            _showThemeSelectionDialog();
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.backup, color: Colors.blue),
                          title: const Text("Chat Backup"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatBackupScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.attach_money, color: Colors.blue),
                          title: const Text("Get Premium"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GetPremiumScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          title: const Text("Delete Account"),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Logout",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          content: const Text("Do you really want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Select Theme",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.phone_android, color: Colors.blue),
                title: const Text("Device Default"),
                trailing: _selectedTheme == AppTheme.deviceDefault
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedTheme = AppTheme.deviceDefault;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Theme set to Device Default")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode, color: Colors.blue),
                title: const Text("Light"),
                trailing: _selectedTheme == AppTheme.light
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedTheme = AppTheme.light;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Theme set to Light")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.blue),
                title: const Text("Dark"),
                trailing: _selectedTheme == AppTheme.dark
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedTheme = AppTheme.dark;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Theme set to Dark")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens, color: Colors.blue),
                title: const Text("Custom"),
                trailing: _selectedTheme == AppTheme.custom
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedTheme = AppTheme.custom;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Theme set to Custom")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
