import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Google Keep-style note colors
  static const List<Color> noteColors = [
    Color(0xFF202124), // 0 - Default (dark)
    Color(0xFF5C2B29), // 1 - Coral / Brown-red
    Color(0xFF1E504A), // 2 - Teal
    Color(0xFF42275E), // 3 - Lavender / Purple
    Color(0xFF2D4A1E), // 4 - Mint / Green
    Color(0xFF614A19), // 5 - Peach / Orange
    Color(0xFF1A3A5C), // 6 - Sky / Blue
  ];

  static const List<Color> noteAccentColors = [
    Color(0xFF5F6368), // 0 - Default accent
    Color(0xFFF28B82), // 1 - Coral
    Color(0xFF7FDBDA), // 2 - Teal
    Color(0xFFD7AEFB), // 3 - Lavender
    Color(0xFFCCFF90), // 4 - Mint
    Color(0xFFFBBC04), // 5 - Peach
    Color(0xFFAECBFA), // 6 - Sky
  ];

  static const List<String> colorNames = [
    'Default',
    'Coral',
    'Teal',
    'Lavender',
    'Mint',
    'Peach',
    'Sky',
  ];

  // Card colors (lighter versions for card backgrounds in dark mode)
  static const List<Color> cardColors = [
    Color(0xFF2D2E30), // 0 - Default card
    Color(0xFF77172E), // 1 - Coral card
    Color(0xFF0C625D), // 2 - Teal card
    Color(0xFF5B2C6F), // 3 - Lavender card
    Color(0xFF345920), // 4 - Mint card
    Color(0xFF7F6000), // 5 - Peach card
    Color(0xFF1A4472), // 6 - Sky card
  ];

  static Color getCardColor(int index) {
    if (index >= 0 && index < cardColors.length) return cardColors[index];
    return cardColors[0];
  }

  static Color getAccentColor(int index) {
    if (index >= 0 && index < noteAccentColors.length) {
      return noteAccentColors[index];
    }
    return noteAccentColors[0];
  }

  static const List<Color> lightCardColors = [
    Colors.white, // 0 - Default
    Color(0xFFFFEBEE), // 1 - Light Coral
    Color(0xFFE0F2F1), // 2 - Light Teal
    Color(0xFFF3E5F5), // 3 - Light Lavender
    Color(0xFFE8F5E9), // 4 - Light Mint
    Color(0xFFFFF3E0), // 5 - Light Peach
    Color(0xFFE3F2FD), // 6 - Light Sky
  ];

  static Color getLightCardColor(int index) {
    if (index >= 0 && index < lightCardColors.length) return lightCardColors[index];
    return lightCardColors[0];
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF1976D2), // Blue
        secondary: const Color(0xFFFBBC04),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        outline: const Color(0xFF747775),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF5F5F5),
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF202124), // Dark FAB for contrast
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.outfit(
          color: const Color(0xFF5F6368),
          fontSize: 16,
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF202124),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF5F6368),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE0E0E0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF323232),
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF8AB4F8),
        secondary: const Color(0xFFFBBC04),
        surface: const Color(0xFF1E1E1E),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        outline: const Color(0xFF5F6368),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2E30),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF8AB4F8),
        foregroundColor: Colors.black,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.outfit(
          color: const Color(0xFF9AA0A6),
          fontSize: 16,
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFE8EAED),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9AA0A6),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF2D2E30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF3C4043),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF323232),
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
