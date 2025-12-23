import 'package:flutter/material.dart';

class AppFonts {
  static const String primaryFont = 'Manrope';
  static const List<String> fallbackFonts = <String>[
    'Poppins',
    'Roboto',
    'Helvetica',
    'Arial',
  ];

  static TextStyle get headline => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      );

  static TextTheme get textTheme => const TextTheme(
        displaySmall: TextStyle(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );
}
