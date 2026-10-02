import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF2CD4C0);
  static const _secondaryColor = Color(0xFFfc9003);
  static const _errorColor = Color(0xFFCF6679);
  static const _backgroundColor = Color(0xFF080E11);
  static const _backgroundCard = Color(0xFF1A1E23);
  static const _backgroundInput = Color(0xFF1A1E23);
  // static const _backgroundInput = Color(0xFF252540);

  // static const _primaryColor = Color(0xFF6C63FF);
  // static const _secondaryColor = Color(0xFF03DAC6);
  // static const _errorColor = Color(0xFFCF6679);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
        primary: _primaryColor,
        secondary: _secondaryColor,
        error: _errorColor,
        surface: _backgroundCard,
        onSurface: const Color(0xFFE8E8F0),
      ),
      scaffoldBackgroundColor: _backgroundColor,
      cardTheme: CardThemeData(
        color: _backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE8E8F0),
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: _backgroundInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _backgroundInput,
        selectedColor: _primaryColor.withOpacity(0.3),
        labelStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _primaryColor),
      ),
      dividerColor: const Color(0xFF2A2A45),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _backgroundInput,
        contentTextStyle: const TextStyle(color: Color(0xFFE8E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
        primary: _primaryColor,
        secondary: _secondaryColor,
        error: _errorColor,
        surface: const Color(0xFFF5F5FF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F0FA),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E0F0)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF0F0FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEEEEFF),
        selectedColor: _primaryColor.withOpacity(0.2),
        labelStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _primaryColor),
      ),
      dividerColor: const Color(0xFFE0E0F0),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A2E),
        contentTextStyle: const TextStyle(color: Color(0xFFE8E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
