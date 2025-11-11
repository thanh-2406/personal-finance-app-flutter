// =======================================================================
// lib/core/app_theme.dart
// (This is the CORRECT file with CardThemeData and const)
// =======================================================================

import 'package:flutter/material.dart';

class AppTheme {
  // Primary color as specified
  static const Color _primaryColor = Color(0xFF1F3A93);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Sans-serif',
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    
    appBarTheme: const AppBarTheme( // <-- Added const
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      iconTheme: IconThemeData(color: _primaryColor),
      titleTextStyle: TextStyle(
        color: _primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // THE FIX IS HERE: It's 'CardThemeData', not 'CardTheme'
    cardTheme: CardThemeData( // <-- FIX
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
      ),
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}