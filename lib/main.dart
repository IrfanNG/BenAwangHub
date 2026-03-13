import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'services/translation_manager.dart';
import 'services/auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  runApp(
    ChangeNotifierProvider(
      create: (_) => TranslationManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final translationManager = Provider.of<TranslationManager>(context);

    return MaterialApp(
      title: 'BenAwang Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: translationManager.currentLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('ms'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 👇 App routing
      home: const AuthWrapper(),
      routes: {
        "/login": (_) => const LoginScreen(),
        "/home": (_) => const HomeScreen(),
        "/profile": (_) => const ProfileScreen(),
      },
    );
  }
}
