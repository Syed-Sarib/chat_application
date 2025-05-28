import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/provider/theme_provider.dart'; // Import ThemeProvider
import '/screens/welcome_screen.dart';
import '/screens/login_screen.dart';
import '/screens/signup_screen.dart';
import '/screens/home_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/group_screen.dart';
import '/screens/friend_request_screen.dart';
import '/screens/status_screen.dart';
import '/screens/call_screen.dart';
import '/screens/chat_screen.dart';
import '/screens/otp_verification_screen.dart';
import '/screens/no_internet_screen.dart';
import '/services/connectivity_service.dart';
import '/api/apis.dart';
import '/screens/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize APIs and user data
  await APIs.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ChatApp(),
    ),
  );
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectionStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              title: 'Chat App',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.themeData, // Apply the selected theme
              home: isConnected ? SplashScreen() : const NoInternetScreen(),
              routes: {
                '/welcome': (context) => WelcomeScreen(),
                '/login': (context) => LoginScreen(),
                '/signup': (context) => SignupScreen(),
                '/home': (context) => HomeScreen(),
                '/profile': (context) => ProfileScreen(),
                '/group': (context) => GroupScreen(),
                '/friend_request': (context) => FriendRequestScreen(),
                '/status': (context) => StatusScreen(),
                '/call': (context) => CallScreen(
                      callerName: 'Caller Name',
                      callerImageUrl: 'https://via.placeholder.com/150',
                    ),
                '/chat': (context) => ChatScreen(),
                '/otp_verification': (context) => OtpVerificationScreen(
                      username: '',
                      email: '',
                      password: '',
                      isLogin: true,
                    ),
              },
            );
          },
        );
      },
    );
  }
}
