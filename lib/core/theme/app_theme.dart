import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 221, 73, 47),
      primary: const Color.fromARGB(255, 218, 95, 33),
      secondary: AppColors.secondary,
      surface: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: TextTheme(
      headlineSmall: AppFonts.headline,
      bodyMedium: AppFonts.body,
      bodySmall: AppFonts.caption,
    ),
    useMaterial3: true,
  );
}
