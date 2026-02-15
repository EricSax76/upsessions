import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/profile/cubit/account_settings_cubit.dart';

void main() {
  group('AccountSettingsCubit', () {
    test('initial state is correct', () {
       expect(AccountSettingsCubit().state, const AccountSettingsState(twoFactorEnabled: false, newsletterEnabled: true));
    });

    blocTest<AccountSettingsCubit, AccountSettingsState>(
      'toggleTwoFactor updates state',
      build: () => AccountSettingsCubit(),
      act: (cubit) => cubit.toggleTwoFactor(true),
      expect: () => [
        const AccountSettingsState(twoFactorEnabled: true, newsletterEnabled: true),
      ],
    );

    blocTest<AccountSettingsCubit, AccountSettingsState>(
      'toggleNewsletter updates state',
      build: () => AccountSettingsCubit(),
      act: (cubit) => cubit.toggleNewsletter(false),
      expect: () => [
        const AccountSettingsState(twoFactorEnabled: false, newsletterEnabled: false),
      ],
    );
  });
}
