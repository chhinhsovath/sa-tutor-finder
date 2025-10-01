import 'package:flutter/material.dart';

class AppTheme {
  // Colors matching the HTML design
  static const Color primary = Color(0xFF1193D4);

  // Light theme colors
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color textLight = Color(0xFF111827);
  static const Color subtextLight = Color(0xFF6B7280);
  static const Color inputLight = Color(0xFFE5E7EB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF101C22);
  static const Color textDark = Color(0xFFF3F4F6);
  static const Color subtextDark = Color(0xFF9CA3AF);
  static const Color inputDark = Color(0xFF374151);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color borderDark = Color(0xFF374151);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'Inter',

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: primary,
      surface: surfaceLight,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textLight,
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceLight,
      elevation: 0,
      iconTheme: IconThemeData(color: textLight),
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: subtextLight),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    ),

    cardTheme: const CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textLight),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textLight),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textLight),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textLight),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textLight),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textLight),
      bodyLarge: TextStyle(fontSize: 16, color: textLight),
      bodyMedium: TextStyle(fontSize: 14, color: textLight),
      bodySmall: TextStyle(fontSize: 12, color: subtextLight),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: subtextLight),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'Inter',

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: surfaceDark,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: subtextDark),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    ),

    cardTheme: const CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
      bodyLarge: TextStyle(fontSize: 16, color: textDark),
      bodyMedium: TextStyle(fontSize: 14, color: textDark),
      bodySmall: TextStyle(fontSize: 12, color: subtextDark),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: subtextDark),
    ),
  );
}
