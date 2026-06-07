import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static const double radius = 20;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.deepOceanBlue,
      brightness: Brightness.light,
      primary: AppColors.deepOceanBlue,
      secondary: AppColors.softOrange,
      tertiary: AppColors.warmYellow,
      surface: AppColors.softWhite,
    );
    final poppins = GoogleFonts.poppinsTextTheme();
    final playfair = GoogleFonts.playfairDisplayTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.softWhite,
      textTheme: _textTheme(poppins, playfair, AppColors.ink),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.softWhite,
        foregroundColor: AppColors.deepOceanBlue,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.deepOceanBlue,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: _cardTheme(AppColors.paper),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.softWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: _inputTheme(colorScheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepOceanBlue,
          foregroundColor: AppColors.softWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepOceanBlue,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.deepOceanBlue,
          foregroundColor: AppColors.softWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.warmYellow,
        foregroundColor: AppColors.deepOceanBlue,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.iceBlue.withAlpha(120),
        selectedColor: AppColors.warmYellow.withAlpha(180),
        secondarySelectedColor: AppColors.warmYellow,
        labelStyle: GoogleFonts.poppins(color: AppColors.deepOceanBlue),
        secondaryLabelStyle: GoogleFonts.poppins(
          color: AppColors.deepOceanBlue,
        ),
        side: BorderSide(color: AppColors.deepOceanBlue.withAlpha(35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepOceanBlue,
        contentTextStyle: GoogleFonts.poppins(color: AppColors.softWhite),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.deepOceanBlue,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.poppins(color: AppColors.ink),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.iceBlue,
      brightness: Brightness.dark,
      primary: AppColors.iceBlue,
      secondary: AppColors.softOrange,
      tertiary: AppColors.warmYellow,
      surface: AppColors.darkSurface,
    );
    final poppins = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    final playfair = GoogleFonts.playfairDisplayTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF081A2A),
      textTheme: _textTheme(poppins, playfair, AppColors.softWhite),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF081A2A),
        foregroundColor: AppColors.iceBlue,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.iceBlue,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: _cardTheme(AppColors.darkSurface),
      inputDecorationTheme: _inputTheme(colorScheme),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.warmYellow,
        foregroundColor: AppColors.deepOceanBlue,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.iceBlue.withAlpha(25),
        selectedColor: AppColors.warmYellow.withAlpha(200),
        labelStyle: GoogleFonts.poppins(color: AppColors.iceBlue),
        side: BorderSide(color: AppColors.iceBlue.withAlpha(45)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.iceBlue,
        contentTextStyle: GoogleFonts.poppins(color: AppColors.deepOceanBlue),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme body, TextTheme display, Color color) {
    return body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: display.displaySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: display.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: body.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: body.titleSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: color),
      bodyMedium: body.bodyMedium?.copyWith(color: color),
      bodySmall: body.bodySmall?.copyWith(color: color.withAlpha(185)),
      labelLarge: body.labelLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static CardThemeData _cardTheme(Color color) {
    return CardThemeData(
      elevation: 0,
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static InputDecorationTheme _inputTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withAlpha(82),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: colorScheme.onSurfaceVariant.withAlpha(170),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(100),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(100),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
    );
  }
}
