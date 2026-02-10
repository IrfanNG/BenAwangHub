import 'package:flutter/material.dart';

import 'home_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final authService = AuthService();
      await authService.signInWithGoogle();

      if (mounted) {
        // AuthWrapper will handle navigation, but if we pushed LoginScreen manually,
        // we might want to pop or replace. Best to let AuthWrapper handle it
        // or push replacement if logic dictates.
        // Assuming AuthWrapper is at root, we just need to ensure state updates or nav happens.
        // If we are using AuthWrapper at root, updates happen automatically via stream.
        // However, if we came here via Navigator.push, we need to pop.
        // For safety, let's pushAndRemoveUntil to Home.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In Failed: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> submit() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill in all fields"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authService = AuthService();
      if (isLogin) {
        await authService.signInWithEmailPassword(
          emailController.text.trim(),
          passwordController.text,
        );
      } else {
        await authService.signUpWithEmailPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
          emailController.text.split("@")[0],
        );
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient or Design Element
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.family_restroom,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "BenAwang Hub",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Connect with your family",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Login/Register Form
          Positioned.fill(
            top: size.height * 0.35,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              isLogin ? "Welcome Back" : "Create Account",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // SizedBox removed to allow button to size based on theme padding
                            ElevatedButton(
                              onPressed: isLoading ? null : submit,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(isLogin ? "Login" : "Register"),
                            ),
                            const SizedBox(height: 16),

                            // Google Sign-In Button
                            OutlinedButton.icon(
                              onPressed: isLoading ? null : _handleGoogleSignIn,
                              icon: const Icon(
                                Icons.login,
                              ), // Replace with specific Google icon if asset available
                              label: const Text("Sign in with Google"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLogin
                                      ? "No account?"
                                      : "Already registered?",
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() => isLogin = !isLogin);
                                    _animationController.reset();
                                    _animationController.forward();
                                  },
                                  child: Text(
                                    isLogin ? "Register now" : "Login",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
