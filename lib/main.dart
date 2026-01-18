import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_theme.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BenAwang Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // 👇 App routing
      initialRoute: "/login",
      routes: {
        "/login": (_) => const LoginScreen(),
        "/home": (_) => const HomeScreen(),
        "/profile": (_) => const ProfileScreen(),
      },
    );
  }
}
