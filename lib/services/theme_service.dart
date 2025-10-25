import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  static const _key = 'isDarkMode';
  final GetStorage _box = GetStorage();

  bool get isDarkMode => _box.read<bool>(_key) ?? false;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleDarkMode(bool enabled) {
    _box.write(_key, enabled);
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeData get lightTheme {
    const primary = Color(0xFF005285);
    const secondary = Color(0xFF4CAF50);
    final colorScheme = const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      error: Colors.red,
      onError: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary),
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: Colors.white),
    );
  }

  ThemeData get darkTheme {
    const primary = Color(0xFF005285);
    const secondary = Color(0xFF4CAF50);
    final colorScheme = const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white70,
      error: Colors.redAccent,
      onError: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: const Color(0xFF1E2227),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary),
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1E2227)),
    );
  }
}