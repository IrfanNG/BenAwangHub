import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Define Colors
  static const Color primaryColor = Color(0xFF0F172A); // Slate 900
  static const Color secondaryColor = Color(0xFF3B82F6); // Blue 500
  static const Color accentColor = Color(0xFF0EA5E9); // Sky 500
  static const Color backgroundColor = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444); // Red 500

  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textLight = Color(0xFF94A3B8); // Slate 400

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Premium Palette: Dominant White/Black, Subtle Greys
      colorScheme: ColorScheme.light(
        primary: primaryColor, // Dark Slate
        secondary:
            primaryColor, // Use primary for secondary to keep it monochrome/premium
        surface: surfaceColor,
        background: Colors.white,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        outline: Colors.grey.shade300,
      ),
      scaffoldBackgroundColor: Colors.white, // Meta apps are usually pure white
      fontFamily:
          'Roboto', // Keep Roboto or switch to system default if preferred
      // AppBar Theme: Clean, minimal, no shadow
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true, // Center title is very standard in iOS/Premium apps
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17, // Standard iOS/Meta size
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),

      // Text Theme: High contrast, readable
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20, // Slightly larger headers
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary, height: 1.4),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Input Decoration: Mineral/Clean
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB), // Very light grey
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300), // Subtle border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
      ),

      // Button Theme: Solid, Pill or Rounded
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Black/Dark Slate
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              30,
            ), // Pill shape for modern feel
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Card Theme: Subtle or Flat
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300), // Darker outline
        ),
        margin: EdgeInsets.zero,
      ),

      iconTheme: const IconThemeData(color: textPrimary, size: 24),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300, // Darker divider
        thickness: 1,
        space: 1,
      ),
      dividerColor: Colors.grey.shade300,
    );
  }
}
