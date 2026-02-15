import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.darkMode = false,
    this.notifications = true,
  });

  final bool darkMode;
  final bool notifications;

  SettingsState copyWith({
    bool? darkMode,
    bool? notifications,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [darkMode, notifications];
}
