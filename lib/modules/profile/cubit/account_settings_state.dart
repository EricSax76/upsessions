part of 'account_settings_cubit.dart';

class AccountSettingsState extends Equatable {
  const AccountSettingsState({
    this.twoFactorEnabled = false,
    this.newsletterEnabled = true,
  });

  final bool twoFactorEnabled;
  final bool newsletterEnabled;

  AccountSettingsState copyWith({
    bool? twoFactorEnabled,
    bool? newsletterEnabled,
  }) {
    return AccountSettingsState(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      newsletterEnabled: newsletterEnabled ?? this.newsletterEnabled,
    );
  }

  @override
  List<Object> get props => [twoFactorEnabled, newsletterEnabled];
}
