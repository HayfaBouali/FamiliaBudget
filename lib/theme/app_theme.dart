import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary    = Color(0xFF6C3FD4);
  static const Color secondary  = Color(0xFF9B6FE8);
  static const Color background = Color(0xFFF5F7FF);
  static const Color cardColor  = Color(0xFFFFFFFF);
  static const Color textDark   = Color(0xFF1A1D3B);
  static const Color textGrey   = Color(0xFF8F90A6);
  static const Color error      = Color(0xFFFF5C5C);

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20, vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),
  );
}