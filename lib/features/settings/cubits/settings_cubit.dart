import 'package:flutter_bloc/flutter_bloc.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void toggleDarkMode(bool value) {
    emit(state.copyWith(darkMode: value));
  }

  void toggleNotifications(bool value) {
    emit(state.copyWith(notifications: value));
  }
}
