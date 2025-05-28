import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBackupScreen extends StatefulWidget {
  const ChatBackupScreen({super.key});

  @override
  State<ChatBackupScreen> createState() => _ChatBackupScreenState();
}

class _ChatBackupScreenState extends State<ChatBackupScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.metadata.readonly',
      'https://www.googleapis.com/auth/drive.readonly',
    ],
  );

  GoogleSignInAccount? _currentUser;
  String? _totalStorage;
  String? _usedStorage;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _fetchDriveStorageDetails();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _fetchDriveStorageDetails() async {
    if (_currentUser == null) return;

    final authHeaders = await _currentUser!.authHeaders;
    final httpClient = GoogleHttpClient(authHeaders);
    final response = await httpClient.get(
      Uri.parse('https://www.googleapis.com/drive/v3/about?fields=storageQuota'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final storageQuota = data['storageQuota'];
      setState(() {
        _totalStorage = _formatBytes(int.parse(storageQuota['limit']));
        _usedStorage = _formatBytes(int.parse(storageQuota['usage']));
      });
    } else {
      setState(() {
        _totalStorage = 'Error fetching storage details';
        _usedStorage = null;
      });
    }
  }

  String _formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<void> _handleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        setState(() {
          _currentUser = account;
        });
        _fetchDriveStorageDetails();
      }
    } catch (error) {
      print('Error signing in: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $error')),
      );
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
      _totalStorage = null;
      _usedStorage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Backup"),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Chat Backup allows you to store your chats securely on Google Drive and restore them later. Select an account to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            if (_currentUser == null) ...[
              ElevatedButton(
                onPressed: _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded rectangle shape
                  ),
                ),
                child: const Text(
                  "Sign in with Google",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ] else ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(_currentUser!.photoUrl ?? ''),
                ),
                title: Text(_currentUser!.displayName ?? ''),
                subtitle: Text(_currentUser!.email),
              ),
              const SizedBox(height: 20),
              if (_totalStorage != null && _usedStorage != null) ...[
                Text(
                  "Total Storage: $_totalStorage",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Used Storage: $_usedStorage",
                  style: const TextStyle(fontSize: 16),
                ),
              ] else ...[
                const CircularProgressIndicator(),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSignOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded rectangle shape
                  ),
                ),
                child: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Automatic backups enabled!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded rectangle shape
                  ),
                ),
                child: const Text(
                  "Enable Automatic Backups",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}