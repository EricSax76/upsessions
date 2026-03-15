import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_localizations.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('es'));

  void changeLocale(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      emit(locale);
    }
  }
}
