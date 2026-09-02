import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Display
  static TextStyle get displayLarge => GoogleFonts.ebGaramond(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 56,
      );

  static TextStyle get displayMedium => GoogleFonts.ebGaramond(
        fontSize: 45,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 45,
      );

  static TextStyle get displaySmall => GoogleFonts.ebGaramond(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.01 * 36,
      );

  // Headline (EB Garamond)
  static TextStyle get headlineLarge => GoogleFonts.ebGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 40 / 32,
      );

  static TextStyle get headlineMedium => GoogleFonts.ebGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 36 / 28,
      );

  static TextStyle get headlineSmall => GoogleFonts.ebGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 32 / 24,
      );

  // Title (EB Garamond)
  static TextStyle get titleLarge => GoogleFonts.ebGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 32 / 24,
      );

  static TextStyle get titleMedium => GoogleFonts.ebGaramond(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => GoogleFonts.ebGaramond(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  // Body (Plus Jakarta Sans)
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 28 / 18,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 24 / 16,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  // Label (Plus Jakarta Sans)
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        height: 20 / 14,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05,
        height: 16 / 12,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05,
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
