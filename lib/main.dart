import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemChrome
import '/screens/splash_screen.dart';
import '/screens/welcome_screen.dart';
import '/screens/login_screen.dart';
import '/screens/signup_screen.dart';
import '/screens/home_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/group_screen.dart';
import '/screens/group_conversation_screen.dart';
import '/screens/create_group_screen.dart';
import '/screens/change_password_screen.dart';
import '/screens/update_password_screen.dart';
import '/screens/friend_request_screen.dart';
import '/screens/friend_search_screen.dart';
import '/screens/status_screen.dart';
import '/screens/call_screen.dart';
import '/screens/chat_screen.dart';
import '/screens/conversation_screen.dart';
import '/screens/otp_verification_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Set global navigation bar and status bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.blueAccent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/group': (context) =>  GroupScreen(),
        '/group_conversation': (context) => GroupConversationScreen(
              groupName: 'Group Name',
              groupImageUrl: 'https://via.placeholder.com/150',
              participants: [],
            ),
        // '/create_group': (context) => CreateGroupScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/update_password': (context) => const UpdatePasswordScreen(),
        '/friend_request': (context) => const FriendRequestScreen(),
        // '/friend_search': (context) => FriendSearchScreen(),
        '/status': (context) =>  StatusScreen(),
        '/call': (context) => const CallScreen(
              callerName: 'Caller Name',
              callerImageUrl: 'https://via.placeholder.com/150',
            ),
        '/chat': (context) =>  ChatScreen(),
        '/conversation': (context) => const ConversationScreen(
              name: 'User Name',
              imageUrl: 'https://via.placeholder.com/150',
            ),
        '/otp_verification': (context) => const OtpVerificationScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Text(
          'Chat App',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
