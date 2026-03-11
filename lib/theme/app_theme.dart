import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 12 Vibrant CMYK Colors + 1 Default
  static const List<Color> noteColors = [
    Color(0xFF202124), // 0 - Default dark
    Color(0xFFD32F2F), // 1 - Deep Red
    Color(0xFFC2185B), // 2 - Magenta / Deep Pink
    Color(0xFF7B1FA2), // 3 - Purple
    Color(0xFF512DA8), // 4 - Deep Purple
    Color(0xFF303F9F), // 5 - Indigo
    Color(0xFF1976D2), // 6 - Deep Blue
    Color(0xFF00796B), // 7 - Dark Teal
    Color(0xFF388E3C), // 8 - Forest Green
  ];

  static const List<Color> noteAccentColors = [
    Color(0xFF5F6368), // 0 - Default accent
    Color(0xFFD32F2F), // 1 - Deep Red
    Color(0xFFC2185B), // 2 - Magenta / Deep Pink
    Color(0xFF7B1FA2), // 3 - Purple
    Color(0xFF512DA8), // 4 - Deep Purple
    Color(0xFF303F9F), // 5 - Indigo
    Color(0xFF1976D2), // 6 - Deep Blue
    Color(0xFF00796B), // 7 - Dark Teal
    Color(0xFF388E3C), // 8 - Forest Green
  ];

  static const List<String> colorNames = [
    'Default',
    'Deep Red',
    'Magenta',
    'Purple',
    'Deep Purple',
    'Indigo',
    'Deep Blue',
    'Dark Teal',
    'Forest Green',
  ];

  static const List<Color> cardColors = [
    Color(0xFF1C1C1E), // 0 - Default card (Dark Grey)
    Color(0xFFD32F2F), // 1 - Deep Red
    Color(0xFFC2185B), // 2 - Magenta / Deep Pink
    Color(0xFF7B1FA2), // 3 - Purple
    Color(0xFF512DA8), // 4 - Deep Purple
    Color(0xFF303F9F), // 5 - Indigo
    Color(0xFF1976D2), // 6 - Deep Blue
    Color(0xFF00796B), // 7 - Dark Teal
    Color(0xFF388E3C), // 8 - Forest Green
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
    Color(0xFFFFCDD2), // 1 - Light Red
    Color(0xFFF8BBD0), // 2 - Light Magenta
    Color(0xFFE1BEE7), // 3 - Light Purple
    Color(0xFFD1C4E9), // 4 - Light Deep Purple
    Color(0xFFC5CAE9), // 5 - Light Indigo
    Color(0xFFBBDEFB), // 6 - Light Blue
    Color(0xFFB2DFDB), // 7 - Light Teal
    Color(0xFFC8E6C9), // 8 - Light Green
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
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
      scaffoldBackgroundColor: Colors.black, // Pitch Black as requested
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF8AB4F8),
        secondary: const Color(0xFFFBBC04),
        surface: const Color(0xFF1E1E1E), // Cards remain slightly lighter for contrast
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        outline: const Color(0xFF5F6368),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black, // Match Scaffold
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // No tint on scroll
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2E30),
        elevation: 0, // Flat on black
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white24, width: 1), // Thin border for visibility on black
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF8AB4F8),
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.roboto(
          color: const Color(0xFF9AA0A6),
          fontSize: 17,
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        headlineLarge: GoogleFonts.roboto(
          fontSize: 24, 
          fontWeight: FontWeight.w400, 
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.roboto(
          fontSize: 19, // Slightly bigger title
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.3,
        ),
        titleMedium: GoogleFonts.roboto(
          fontSize: 17, // Secondary text bump
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 18, // Bumped from 17 to 18 ("Little Bit More Bigger")
          fontWeight: FontWeight.w400,
          color: const Color(0xFFE8EAED),
          height: 1.5,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 16, // Bumped from 15 to 16
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9AA0A6),
          height: 1.5,
          letterSpacing: 0.25,
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
