import 'dart:async';

import 'package:bloc/bloc.dart';

import '../models/notification_preferences_entity.dart';
import '../models/notification_scenario.dart';
import '../repositories/notification_preferences_repository.dart';
import 'notification_preferences_state.dart';

class NotificationPreferencesCubit extends Cubit<NotificationPreferencesState> {
  NotificationPreferencesCubit({
    required NotificationPreferencesRepository repository,
  }) : _repository = repository,
       super(const NotificationPreferencesState()) {
    _start();
  }

  final NotificationPreferencesRepository _repository;
  StreamSubscription<NotificationPreferencesEntity>? _subscription;

  void _start() {
    emit(state.copyWith(status: NotificationPreferencesStatus.loading));
    _subscription = _repository.watchPreferences().listen(
      (entity) {
        emit(
          state.copyWith(
            status: NotificationPreferencesStatus.success,
            entity: entity,
            errorMessage: null,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: NotificationPreferencesStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> toggleChannel(
    NotificationScenario scenario,
    NotificationChannel channel,
  ) async {
    final enabled = state.entity.isChannelEnabled(scenario, channel);
    await setScenarioChannel(scenario, channel, !enabled);
  }

  Future<void> setScenarioChannel(
    NotificationScenario scenario,
    NotificationChannel channel,
    bool enabled,
  ) async {
    final previous = state.entity;
    final optimistic = _withScenarioChannel(
      previous,
      scenario,
      channel,
      enabled,
    );
    emit(
      state.copyWith(
        status: NotificationPreferencesStatus.success,
        entity: optimistic,
        errorMessage: null,
      ),
    );

    try {
      await _repository.setScenarioChannel(scenario, channel, enabled);
    } catch (error) {
      emit(
        state.copyWith(
          status: NotificationPreferencesStatus.failure,
          entity: previous,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> toggleQuietHours() async {
    await setQuietHours(
      enabled: !state.entity.quietHoursEnabled,
      start: state.entity.quietStartHour,
      end: state.entity.quietEndHour,
    );
  }

  Future<void> setQuietRange(int start, int end) async {
    await setQuietHours(
      enabled: state.entity.quietHoursEnabled,
      start: start,
      end: end,
    );
  }

  Future<void> setQuietHours({
    required bool enabled,
    required int start,
    required int end,
  }) async {
    final previous = state.entity;
    final optimistic = previous.copyWith(
      quietHours: previous.quietHours.copyWith(
        enabled: enabled,
        startHour: start,
        endHour: end,
      ),
    );
    emit(
      state.copyWith(
        status: NotificationPreferencesStatus.success,
        entity: optimistic,
        errorMessage: null,
      ),
    );

    try {
      await _repository.setQuietHours(enabled: enabled, start: start, end: end);
    } catch (error) {
      emit(
        state.copyWith(
          status: NotificationPreferencesStatus.failure,
          entity: previous,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  NotificationPreferencesEntity _withScenarioChannel(
    NotificationPreferencesEntity entity,
    NotificationScenario scenario,
    NotificationChannel channel,
    bool enabled,
  ) {
    final channelsByScenario = <String, Map<String, bool>>{};
    for (final entry in entity.scenarioChannels.entries) {
      channelsByScenario[entry.key] = Map<String, bool>.from(entry.value);
    }
    final scenarioChannels = Map<String, bool>.from(
      channelsByScenario[scenario.wireKey] ?? const <String, bool>{},
    );
    scenarioChannels[NotificationPreferencesEntity.channelFieldName(channel)] =
        enabled;
    channelsByScenario[scenario.wireKey] = scenarioChannels;
    return entity.copyWith(scenarioChannels: channelsByScenario);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
