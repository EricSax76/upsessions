import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_localizations.dart';

/// Manages the active [Locale] of the application.
class LocaleCubit extends Cubit<Locale> {
  // Default to Spanish ('es')
  LocaleCubit() : super(const Locale('es'));

  void changeLocale(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      emit(locale);
    }
  }
}
