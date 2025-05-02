import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

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
    return (_scrollOffset / 150).clamp(0.0, 1.0); // Adjust this for speed
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = lerpDouble(100, 36, _headerAnimationProgress)!;
    final topPadding = lerpDouble(40, 12, _headerAnimationProgress)!;
    final leftPadding = lerpDouble(MediaQuery.of(context).size.width / 2 - 50, 16, _headerAnimationProgress)!;
    final nameFontSize = lerpDouble(24, 16, _headerAnimationProgress)!;
    final subtitleOpacity = (1 - _headerAnimationProgress).clamp(0.0, 1.0);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // SliverAppBar with dynamic title and content
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            automaticallyImplyLeading: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: 16, bottom: 16),
                  title: Opacity(
                    opacity: _headerAnimationProgress,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: imageSize / 2,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: imageSize / 2 - 4,
                            backgroundImage: AssetImage("assets/images/user.jpg"),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Sarib",
                          style: TextStyle(fontSize: nameFontSize),
                        ),
                      ],
                    ),
                  ),
                  background: Container(), // Empty, we use below widget
                );
              },
            ),
          ),

          // Profile Card and Rest
          SliverToBoxAdapter(
            child: Column(
              children: [
                Stack(
                  children: [
                    // Profile Card
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
                                duration: Duration(milliseconds: 200),
                                opacity: 1 - _headerAnimationProgress,
                                child: Column(
                                  children: [
                                    Text("@Sarib", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text("Frontend Developer", style: TextStyle(color: Colors.grey[700])),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              ),
                              infoRow("Email", "233505@students.au.edu.pk"),
                              infoRow("Join Date", "2025-01-01"),
                              infoRow("User Tier", "Premium"),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.edit),
                                label: Text("Edit Profile"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Profile Image (Card Layer)
                    Positioned(
                      top: topPadding,
                      left: leftPadding,
                      child: AnimatedOpacity(
                        opacity: 1 - _headerAnimationProgress,
                        duration: Duration(milliseconds: 200),
                        child: CircleAvatar(
                          radius: imageSize / 2,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: imageSize / 2 - 4,
                            backgroundImage: AssetImage("assets/images/user.jpg"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Logout Button (Wide)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 8),

                // Settings Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.lock, color: Colors.blue),
                          title: Text("Change Password"),
                          onTap: () {},
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.color_lens, color: Colors.blue),
                          title: Text("Change Theme"),
                          onTap: () {},
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.backup, color: Colors.blue),
                          title: Text("Chat Backup"),
                          onTap: () {},
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.attach_money, color: Colors.blue),
                          title: Text("Get Premium"),
                          onTap: () {},
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.delete_forever, color: Colors.red),
                          title: Text("Delete Account"),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40),
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
          Icon(Icons.info_outline, size: 18, color: Colors.blue),
          SizedBox(width: 8),
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
