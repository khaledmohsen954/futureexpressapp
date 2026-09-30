import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared palette and typography from the Future Express Figma design.
abstract final class AppColors {
  static const navy = Color(0xFF101A32);
  static const red = Color(0xFFD8102D);
  static const background = Color(0xFFF6F8FC);
  static const surface = Color(0xFFFFFFFF);
  static const muted = Color(0xFF8490A0);
  static const green = Color(0xFF078B6C);
  static const border = Color(0xFFE9EDF3);
  static const paleRed = Color(0xFFFFEDF0);
  static const onDark = Color(0xFFFFFFFF);
  static const onDarkMuted = Color(0xB3FFFFFF);
  static const success = Color(0xFF078B6C);
  static const warning = Color(0xFFFFCC00);
  static const offline = Color(0xFF616161);
  static const info = Color(0xFF0091EA);
  static const blue = Color(0xFFBDD6FF);
  static const white = Color(0xFFFFFFFF);
}

ThemeData appTheme() {
  final textTheme = GoogleFonts.tajawalTextTheme().copyWith(
    displaySmall:
        GoogleFonts.tajawal(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.navy),
    headlineSmall:
        GoogleFonts.tajawal(fontSize: 23, fontWeight: FontWeight.w800, color: AppColors.navy),
    titleLarge:
        GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy),
    titleMedium:
        GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
    titleSmall:
        GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.navy),
    bodyLarge: GoogleFonts.tajawal(fontSize: 16, color: AppColors.navy),
    bodyMedium: GoogleFonts.tajawal(fontSize: 14, color: AppColors.navy),
    bodySmall: GoogleFonts.tajawal(fontSize: 12, color: AppColors.muted),
    labelLarge:
        GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
  );
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.red).copyWith(
      primary: AppColors.red,
      secondary: AppColors.navy,
      surface: AppColors.surface,
      error: AppColors.red,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge,
      foregroundColor: AppColors.navy,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: textTheme.labelLarge,
        foregroundColor: AppColors.onDark,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15)),
  );
}
