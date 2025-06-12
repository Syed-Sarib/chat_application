import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/provider/theme_provider.dart';
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

// Custom light theme with ebebeb background
final ThemeData customLightTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFebebeb),
  colorScheme: ColorScheme.light(
    primary: Colors.blue, // Primary color for app bars
    onPrimary: Colors.white, // Text/icon color on primary
    surface: Colors.white, // Surface color for cards
    onSurface: Colors.black87, // Text color on surface
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue, // App bar background
    elevation: 1,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white, // White text for title
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    toolbarTextStyle: TextStyle(
      color: Colors.white, // White text for toolbar items
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 1,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);

// Custom dark theme
final ThemeData customDarkTheme = ThemeData.dark().copyWith(
  colorScheme: ColorScheme.dark(
    primary: Colors.blueGrey,
    onPrimary: Colors.white,
    surface: Colors.grey,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blueGrey,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await APIs.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider()..initializeThemes(
        customLightTheme: customLightTheme,
        customDarkTheme: customDarkTheme,
      ),
      child: const ChatApp(),
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
              theme: themeProvider.currentLightTheme,
              darkTheme: themeProvider.currentDarkTheme,
              themeMode: themeProvider.isSystemTheme 
                  ? ThemeMode.system 
                  : (themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light),
              home: isConnected ? const SplashScreen() : const NoInternetScreen(),
              routes: {
                '/welcome': (context) => Scaffold(
                  body: const WelcomeScreen(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/login': (context) => Scaffold(
                  body: const LoginScreen(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/signup': (context) => Scaffold(
                  body: const SignupScreen(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/home': (context) => Scaffold(
                  body: const HomeScreen(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/profile': (context) => Scaffold(
                  body: const ProfileScreen(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/group': (context) => Scaffold(
                  body: const GroupScreen(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/friend_request': (context) => Scaffold(
                  body: const FriendRequestScreen(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/status': (context) => Scaffold(
                  body: const StatusScreen(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/call': (context) => Scaffold(
                  body: CallScreen(
                    callerName: 'Caller Name',
                    callerImageUrl: 'https://via.placeholder.com/150',
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/chat': (context) => Scaffold(
                  body: const ChatScreen(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                '/otp_verification': (context) => Scaffold(
                  body: OtpVerificationScreen(
                    username: '',
                    email: '',
                    password: '',
                    isLogin: true,
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              },
            );
          },
        );
      },
    );
  }
}