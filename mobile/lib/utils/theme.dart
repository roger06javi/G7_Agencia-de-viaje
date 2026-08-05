import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary    = Color(0xFF6366F1);
  static const Color primaryDark= Color(0xFF4F46E5);
  static const Color bg         = Color(0xFF0B0F1A);
  static const Color surface    = Color(0xFF131929);
  static const Color surface2   = Color(0xFF1E293B);
  static const Color border     = Color(0xFF1E293B);
  static const Color textPrimary= Color(0xFFF1F5F9);
  static const Color textMuted  = Color(0xFF64748B);
  static const Color success    = Color(0xFF10B981);
  static const Color error      = Color(0xFFEF4444);
  static const Color warning    = Color(0xFFF59E0B);
  static const Color info       = Color(0xFF3B82F6);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: surface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: surface),
    cardTheme: CardThemeData(
      color: surface, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: textMuted),
      hintStyle: const TextStyle(color: textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primary),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary, foregroundColor: Colors.white,
    ),
    dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.06)),
    listTileTheme: const ListTileThemeData(textColor: textPrimary, iconColor: textMuted),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textMuted),
      labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
    ),
  );
}
