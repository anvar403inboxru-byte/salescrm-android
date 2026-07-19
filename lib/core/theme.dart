import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Əsas rənglər
  static const Color primary     = Color(0xFF6366F1); // indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryGlow = Color(0xFF818CF8); // açıq indigo
  static const Color success     = Color(0xFF10B981);
  static const Color danger      = Color(0xFFEF4444);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color info        = Color(0xFF38BDF8);

  // Fon rəngləri
  static const Color bg          = Color(0xFF0A0F1E); // dərin tünd göy
  static const Color surface     = Color(0xFF141929); // kart fonu
  static const Color surface2    = Color(0xFF1E2540); // input fonu
  static const Color surface3    = Color(0xFF252D4A); // hover fonu
  static const Color border      = Color(0xFF2E3759);
  static const Color borderLight = Color(0xFF3D4A6B);

  // Mətn rəngləri
  static const Color textMain    = Color(0xFFE8EDF7);
  static const Color textSub     = Color(0xFFB0BBDA);
  static const Color textMuted   = Color(0xFF6B7BB0);

  static ThemeData dark() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryGlow,
        surface: surface,
        error: danger,
        onPrimary: Colors.white,
        onSurface: textMain,
      ),
      cardColor: surface,
      dividerColor: border,

      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: textMain),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      textTheme: const TextTheme(
        displayLarge:  TextStyle(color: textMain, fontSize: 32, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: textMain, fontSize: 26, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: textMain, fontSize: 22, fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge:    TextStyle(color: textMain, fontSize: 17, fontWeight: FontWeight.w600),
        titleMedium:   TextStyle(color: textMain, fontSize: 15, fontWeight: FontWeight.w600),
        titleSmall:    TextStyle(color: textSub,  fontSize: 13, fontWeight: FontWeight.w500),
        bodyLarge:     TextStyle(color: textMain, fontSize: 14),
        bodyMedium:    TextStyle(color: textSub,  fontSize: 13),
        bodySmall:     TextStyle(color: textMuted,fontSize: 12),
        labelLarge:    TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 13),
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: border,
          disabledForegroundColor: textMuted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGlow,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: primary.withOpacity(0.2),
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(color: textSub, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface3,
        contentTextStyle: const TextStyle(color: textMain, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(color: textMain, fontSize: 17, fontWeight: FontWeight.w600),
        contentTextStyle: const TextStyle(color: textSub, fontSize: 14),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: textMuted,
        textColor: textMain,
        subtitleTextStyle: TextStyle(color: textMuted, fontSize: 12),
      ),
    );
  }

  static ThemeData light() => dark();

  // Hazır badge rəngləri
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':   return success;
      case 'lead':     return info;
      case 'inactive': return textMuted;
      case 'won':      return success;
      case 'lost':     return danger;
      case 'pending':  return warning;
      case 'sent':     return info;
      case 'draft':    return textMuted;
      default:         return textMuted;
    }
  }
}