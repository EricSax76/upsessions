import 'package:flutter/material.dart';

class AppFonts {
  static const String primaryFont = 'Poppins';

  static TextStyle get headline => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 16,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 13,
        color: Colors.grey,
      );
}
