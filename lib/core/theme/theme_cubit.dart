import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit to manage the app's theme mode (light, dark, or system)
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  /// Switch to light theme
  void setLightMode() => emit(ThemeMode.light);

  /// Switch to dark theme
  void setDarkMode() => emit(ThemeMode.dark);

  /// Use system theme
  void setSystemMode() => emit(ThemeMode.system);

  /// Toggle between light and dark (ignore system)
  void toggleTheme() {
    if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.dark);
    }
  }
}
