import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'account_preferences_state.dart';

class AccountPreferencesCubit extends Cubit<AccountPreferencesState> {
  AccountPreferencesCubit() : super(const AccountPreferencesState());

  void toggleTwoFactor(bool value) {
    emit(state.copyWith(twoFactorEnabled: value));
  }

  void toggleNewsletter(bool value) {
    emit(state.copyWith(newsletterEnabled: value));
  }
}
