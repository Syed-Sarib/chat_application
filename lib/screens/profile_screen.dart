import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'chat_backup_screen.dart';
import 'get_premium_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';

enum AppTheme { deviceDefault, light, dark }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  String _profileName = "Loading...";
  String _profileDescription = "Loading...";
  String _profileEmail = "Loading...";
  File? _profileAvatar;
  String _profileAvatarUrl = "";
  String _profileJoinDate = "Loading...";
  String _profileUserTier = "Loading...";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _profileName = userDoc['name'] ?? "Unknown";
            _profileDescription = userDoc['about'] ?? "No description available";
            _profileEmail = userDoc['email'] ?? "No email available";
            _profileAvatarUrl = userDoc['image'] ?? "";
            Timestamp createdAt = userDoc['created_at'] ?? Timestamp.now();
            _profileJoinDate = createdAt.toDate().toString().substring(0, 10);
            _profileUserTier = userDoc['permission'] ?? "Standard";
          });

          if (_profileAvatarUrl.isNotEmpty) {
            await _downloadProfileImage(_profileAvatarUrl);
          }
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
  }

  Future<void> _downloadProfileImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/profile_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _profileAvatar = file;
        });
      } else {
        print('Image not found or invalid URL');
      }
    } catch (e) {
      print('Failed to download image: $e');
    }
  }

  double get _headerAnimationProgress => (_scrollOffset / 150).clamp(0.0, 1.0);

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
            backgroundColor: Colors.blueAccent,
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
                                : _profileAvatarUrl.isNotEmpty
                                    ? NetworkImage(_profileAvatarUrl)
                                    : _getDefaultAvatar(),
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
                    Container(height: 200, width: double.infinity, color: Colors.blueAccent),
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
                              infoRow("Email", _profileEmail),
                              infoRow("Join Date", _profileJoinDate),
                              infoRow("User Tier", _profileUserTier),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        currentName: _profileName,
                                        currentDescription: _profileDescription,
                                      ),
                                    ),
                                  );

                                  if (result != null && result is Map<String, dynamic>) {
                                    setState(() {
                                      _profileName = result['name'];
                                      _profileDescription = result['description'];
                                      _profileAvatar = result['avatar'];
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Profile updated successfully!")),
                                    );

                                    User? user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                        'name': _profileName,
                                        'about': _profileDescription,
                                      });
                                    }
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
                                : _profileAvatarUrl.isNotEmpty
                                    ? NetworkImage(_profileAvatarUrl)
                                    : _getDefaultAvatar(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showLogoutConfirmationDialog,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock, color: Colors.blueAccent),
                          title: const Text("Change Password"),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.color_lens, color: Colors.blueAccent),
                          title: const Text("Change Theme"),
                          onTap: _showThemeSelectionDialog,
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.backup, color: Colors.blueAccent),
                          title: const Text("Chat Backup"),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatBackupScreen()));
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.star, color: Colors.blueAccent),
                          title: const Text("Get Premium"),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const GetPremiumScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Theme"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTheme.values.map((theme) {
            return ListTile(
              title: Text(theme.name),
              onTap: () {
                // Update the theme using ThemeProvider
                final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                if (theme == AppTheme.light) {
                  themeProvider.setLightTheme();
                } else if (theme == AppTheme.dark) {
                  themeProvider.setDarkTheme();
                } else if (theme == AppTheme.deviceDefault) {
                  themeProvider.setSystemTheme();
                }

                Navigator.pop(context); // Close the dialog
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  ImageProvider _getDefaultAvatar() {
    return const AssetImage('assets/images/default_avatar.jpeg');
  }
}
