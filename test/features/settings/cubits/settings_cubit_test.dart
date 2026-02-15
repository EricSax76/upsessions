import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/features/settings/cubits/settings_cubit.dart';
import 'package:upsessions/features/settings/cubits/settings_state.dart';

void main() {
  group('SettingsCubit', () {
    test('initial state has darkMode false and notifications true', () {
      final cubit = SettingsCubit();
      expect(cubit.state.darkMode, false);
      expect(cubit.state.notifications, true);
      cubit.close();
    });

    blocTest<SettingsCubit, SettingsState>(
      'toggleDarkMode emits updated state',
      build: SettingsCubit.new,
      act: (cubit) {
        cubit.toggleDarkMode(true);
        cubit.toggleDarkMode(false);
      },
      expect: () => [
        const SettingsState(darkMode: true, notifications: true),
        const SettingsState(darkMode: false, notifications: true),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'toggleNotifications emits updated state',
      build: SettingsCubit.new,
      act: (cubit) {
        cubit.toggleNotifications(false);
        cubit.toggleNotifications(true);
      },
      expect: () => [
        const SettingsState(darkMode: false, notifications: false),
        const SettingsState(darkMode: false, notifications: true),
      ],
    );
  });
}
