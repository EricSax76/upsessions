import 'package:equatable/equatable.dart';

import '../models/notification_preferences_entity.dart';

enum NotificationPreferencesStatus { initial, loading, success, failure }

class NotificationPreferencesState extends Equatable {
  static const Object _unset = Object();

  const NotificationPreferencesState({
    this.status = NotificationPreferencesStatus.initial,
    this.entity = NotificationPreferencesEntity.defaults,
    this.errorMessage,
  });

  final NotificationPreferencesStatus status;
  final NotificationPreferencesEntity entity;
  final String? errorMessage;

  NotificationPreferencesState copyWith({
    NotificationPreferencesStatus? status,
    NotificationPreferencesEntity? entity,
    Object? errorMessage = _unset,
  }) {
    return NotificationPreferencesState(
      status: status ?? this.status,
      entity: entity ?? this.entity,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, entity, errorMessage];
}
