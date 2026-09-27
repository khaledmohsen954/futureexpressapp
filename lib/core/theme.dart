import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared palette and typography from the Future Express Figma design.
abstract final class AppColors {
  static const navy = Color(0xFF101A32);
  static const red = Color(0xFFD8102D);
  static const background = Color(0xFFF6F8FC);
  static const muted = Color(0xFF8490A0);
  static const green = Color(0xFF078B6C);
  static const border = Color(0xFFE9EDF3);
}

ThemeData appTheme() {
  final textTheme = GoogleFonts.tajawalTextTheme();
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
    textTheme: textTheme.apply(bodyColor: AppColors.navy, displayColor: AppColors.navy),
    appBarTheme: AppBarTheme(backgroundColor: AppColors.background, surfaceTintColor: Colors.transparent,
      centerTitle: true, titleTextStyle: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navy)),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15)),
  );
}
