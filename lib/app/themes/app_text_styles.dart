import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static bool get isKhmer => Get.locale?.languageCode == 'km';
  static TextStyle get headlineLarge =>
      isKhmer
          ? GoogleFonts.googleSans(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            )
          : GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            );
  static TextStyle get headlineMedium =>
      isKhmer
          ? GoogleFonts.googleSans(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            )
          : GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            );
  static TextStyle get headlineSmall =>
      isKhmer
          ? GoogleFonts.googleSans(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            )
          : GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            );

  static TextStyle get titleLarge =>
      isKhmer
          ? GoogleFonts.googleSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )
          : GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            );

  static TextStyle get titleMedium =>
      isKhmer
          ? GoogleFonts.googleSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            )
          : GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            );

  static TextStyle get titleSmall =>
      isKhmer
          ? GoogleFonts.googleSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )
          : GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            );

  static TextStyle get bodyLarge =>
      isKhmer
          ? GoogleFonts.googleSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )
          : GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            );

  static TextStyle get bodyMedium =>
      isKhmer
          ? GoogleFonts.googleSans(fontSize: 14)
          : GoogleFonts.spaceGrotesk(fontSize: 14);

  static TextStyle get bodySmall =>
      isKhmer
          ? GoogleFonts.googleSans(fontSize: 12)
          : GoogleFonts.spaceGrotesk(fontSize: 12);
}