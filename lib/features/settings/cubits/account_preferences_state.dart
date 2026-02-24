part of 'account_preferences_cubit.dart';

class AccountPreferencesState extends Equatable {
  const AccountPreferencesState({
    this.twoFactorEnabled = false,
    this.newsletterEnabled = true,
  });

  final bool twoFactorEnabled;
  final bool newsletterEnabled;

  AccountPreferencesState copyWith({
    bool? twoFactorEnabled,
    bool? newsletterEnabled,
  }) {
    return AccountPreferencesState(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      newsletterEnabled: newsletterEnabled ?? this.newsletterEnabled,
    );
  }

  @override
  List<Object?> get props => [twoFactorEnabled, newsletterEnabled];
}
