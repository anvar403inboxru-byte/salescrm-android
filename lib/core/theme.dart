import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary    = Color(0xFF6366F1); // indigo
  static const Color primaryDark= Color(0xFF4F46E5);
  static const Color success    = Color(0xFF10B981);
  static const Color danger     = Color(0xFFEF4444);
  static const Color warning    = Color(0xFFF59E0B);
  static const Color bg         = Color(0xFF0F172A);
  static const Color surface    = Color(0xFF1E293B);
  static const Color surface2   = Color(0xFF334155);
  static const Color border     = Color(0xFF475569);
  static const Color textMain   = Color(0xFFF1F5F9);
  static const Color textMuted  = Color(0xFF94A3B8);

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: success,
      surface: surface,
      error: danger,
    ),
    cardColor: surface,
    dividerColor: border,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textMain,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      bodyLarge:  TextStyle(color: textMain, fontSize: 14),
      bodyMedium: TextStyle(color: textMain, fontSize: 13),
      bodySmall:  TextStyle(color: textMuted, fontSize: 12),
      titleLarge: TextStyle(color: textMain, fontWeight: FontWeight.w700, fontSize: 18),
      titleMedium:TextStyle(color: textMain, fontWeight: FontWeight.w600, fontSize: 15),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
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
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
  );

  static ThemeData light() => dark(); // eyni dark theme
}