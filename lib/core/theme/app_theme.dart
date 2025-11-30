import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' show Color, TextStyle, FontWeight, RoundedRectangleBorder, BorderRadius, EdgeInsets, Brightness, Colors, Radius;

/// App theme configuration for Solar System Explorer
/// Dark space theme with deep cosmic colors
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // Color palette - Deep Space Theme
  static const Color _deepSpaceBackground = Color(0xFF0A0E27); // Very dark blue-black
  static const Color _spaceBlue = Color(0xFF1A1F3A); // Dark blue surface
  static const Color _cosmicCyan = Color(0xFF00D9FF); // Bright cyan primary
  static const Color _nebulaPurple = Color(0xFF9D4EDD); // Purple accent
  static const Color _starWhite = Color(0xFFE8F4F8); // Slightly blue-tinted white
  static const Color _cardSurface = Color(0xFF151B33); // Card background

  /// Main dark space theme
  static material.ThemeData get darkSpaceTheme {
    return material.ThemeData(
      // Use Material 3
      useMaterial3: true,

      // Brightness
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const material.ColorScheme.dark(
        // Background colors
        surface: _deepSpaceBackground,
        surfaceContainerHighest: _spaceBlue,
        
        // Primary colors
        primary: _cosmicCyan,
        onPrimary: Color(0xFF003544),
        primaryContainer: Color(0xFF004D61),
        onPrimaryContainer: Color(0xFFB8EAFF),
        
        // Secondary colors
        secondary: _nebulaPurple,
        onSecondary: Color(0xFF3D1152),
        secondaryContainer: Color(0xFF551A70),
        onSecondaryContainer: Color(0xFFF2DAFF),
        
        // Error colors
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        
        // Text colors
        onSurface: _starWhite,
      ),

      // Scaffold background
      scaffoldBackgroundColor: _deepSpaceBackground,

      // AppBar theme
      appBarTheme: const material.AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _starWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: material.IconThemeData(
          color: _cosmicCyan,
          size: 24,
        ),
      ),

      // Card theme
      cardTheme: material.CardThemeData(
        color: _cardSurface,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Text theme
      textTheme: const material.TextTheme(
        displayLarge: TextStyle(
          color: _starWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: _starWhite,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: _starWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: _starWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _starWhite,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: _starWhite,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: _starWhite,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: _cosmicCyan,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Icon theme
      iconTheme: const material.IconThemeData(
        color: _cosmicCyan,
        size: 24,
      ),

      // Elevated button theme
      elevatedButtonTheme: material.ElevatedButtonThemeData(
        style: material.ElevatedButton.styleFrom(
          backgroundColor: _cosmicCyan,
          foregroundColor: const Color(0xFF003544),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const material.FloatingActionButtonThemeData(
        backgroundColor: _cosmicCyan,
        foregroundColor: Color(0xFF003544),
        elevation: 6,
      ),

      // Divider theme
      dividerTheme: const material.DividerThemeData(
        color: Color(0xFF2A3348),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
