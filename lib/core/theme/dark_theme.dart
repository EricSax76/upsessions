import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

ThemeData buildDarkTheme() {
  return ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColorsDark.primary,
      onPrimary: AppColorsDark.onPrimary,
      secondary: AppColorsDark.secondary,
      onSecondary: AppColorsDark.onSecondary,
      primaryContainer: AppColorsDark.primaryContainer,
      onPrimaryContainer: AppColorsDark.onPrimaryContainer,
      tertiary: AppColorsDark.tertiary,
      onTertiary: AppColorsDark.onPrimary,
      error: AppColorsDark.danger,
      onError: Color(0xFF1C1B19),
      surface: AppColorsDark.surface,
      onSurface: AppColorsDark.onSurface,
      surfaceContainerHighest: AppColorsDark.surfaceVariant,
      onSurfaceVariant: AppColorsDark.textTertiary,
      outline: AppColorsDark.outline,
      shadow: Color(0x80000000),
      inverseSurface: Color(0xFFF1F5F9),
      onInverseSurface: Color(0xFF1E293B),
      inversePrimary: Color(0xFF4F46E5),
      scrim: Color(0xCC000000),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorsDark.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColorsDark.outline),
      ),
    ),
    scaffoldBackgroundColor: AppColorsDark.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsDark.background,
      foregroundColor: AppColorsDark.textPrimary,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColorsDark.outline,
      thickness: 1,
    ),
    cardTheme: CardThemeData(
      color: AppColorsDark.surface,
      shadowColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColorsDark.outline),
      ),
    ),
    textTheme: AppFonts.textTheme.apply(
      bodyColor: AppColorsDark.textPrimary,
      displayColor: AppColorsDark.textPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsDark.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsDark.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsDark.outlineFocus),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsDark.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsDark.danger),
      ),
      hintStyle: const TextStyle(
        color: AppColorsDark.textTertiary,
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.primary,
        foregroundColor: AppColorsDark.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColorsDark.primary,
        foregroundColor: AppColorsDark.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColorsDark.surface,
        foregroundColor: AppColorsDark.icon,
        side: const BorderSide(color: AppColorsDark.outline),
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsDark.textSecondary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColorsDark.primary,
      foregroundColor: AppColorsDark.onPrimary,
      elevation: 0,
      shape: CircleBorder(),
    ),
    useMaterial3: true,
  );
}
