import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

        class AppTheme {
          static ThemeData get light => ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                  primary: AppColors.primary,
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
