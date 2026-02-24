import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/features/settings/cubits/account_preferences_cubit.dart';

void main() {
  group('AccountPreferencesCubit', () {
    test('initial state is correct', () {
      expect(
        AccountPreferencesCubit().state,
        const AccountPreferencesState(
          twoFactorEnabled: false,
          newsletterEnabled: true,
        ),
      );
    });

    blocTest<AccountPreferencesCubit, AccountPreferencesState>(
      'toggleTwoFactor updates state',
      build: () => AccountPreferencesCubit(),
      act: (cubit) => cubit.toggleTwoFactor(true),
      expect: () => [
        const AccountPreferencesState(
          twoFactorEnabled: true,
          newsletterEnabled: true,
        ),
      ],
    );

    blocTest<AccountPreferencesCubit, AccountPreferencesState>(
      'toggleNewsletter updates state',
      build: () => AccountPreferencesCubit(),
      act: (cubit) => cubit.toggleNewsletter(false),
      expect: () => [
        const AccountPreferencesState(
          twoFactorEnabled: false,
          newsletterEnabled: false,
        ),
      ],
    );
  });
}
