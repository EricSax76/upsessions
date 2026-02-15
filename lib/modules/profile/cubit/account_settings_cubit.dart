import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'account_settings_state.dart';

class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  AccountSettingsCubit() : super(const AccountSettingsState());

  void toggleTwoFactor(bool value) {
    emit(state.copyWith(twoFactorEnabled: value));
  }

  void toggleNewsletter(bool value) {
    emit(state.copyWith(newsletterEnabled: value));
  }
}
