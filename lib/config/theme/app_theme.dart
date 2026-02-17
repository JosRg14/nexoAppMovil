import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color scaffoldBackgroundColor = Color(0xFF1A1A1A);
  static const Color primaryColor = Colors.black;
  static const Color onSurfaceColor = Color(0xFFF3F4F6); // Blanco Hueso

  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        surface: scaffoldBackgroundColor,
        onSurface: onSurfaceColor,
      ),

      // Typography
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: onSurfaceColor,
        displayColor: onSurfaceColor,
      ),

      // Input Decoration (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Text color
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Rectangular
          ),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
