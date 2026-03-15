import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/notifications/cubits/notification_preferences_cubit.dart';
import 'package:upsessions/modules/notifications/cubits/notification_preferences_state.dart';
import 'package:upsessions/modules/notifications/models/notification_preferences_entity.dart';
import 'package:upsessions/modules/notifications/models/notification_scenario.dart';
import 'package:upsessions/modules/notifications/models/quiet_hours_config.dart';
import 'package:upsessions/modules/notifications/repositories/notification_preferences_repository.dart';

class MockNotificationPreferencesRepository extends Mock
    implements NotificationPreferencesRepository {}

void main() {
  late MockNotificationPreferencesRepository repository;
  late StreamController<NotificationPreferencesEntity> controller;

  setUpAll(() {
    registerFallbackValue(NotificationScenario.musicianGroupInvite);
    registerFallbackValue(NotificationChannel.push);
  });

  setUp(() {
    repository = MockNotificationPreferencesRepository();
    controller = StreamController<NotificationPreferencesEntity>.broadcast();

    when(
      () => repository.watchPreferences(),
    ).thenAnswer((_) => controller.stream);
    when(
      () => repository.setScenarioChannel(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => repository.setQuietHours(
        enabled: any(named: 'enabled'),
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await controller.close();
  });

  group('NotificationPreferencesCubit', () {
    blocTest<NotificationPreferencesCubit, NotificationPreferencesState>(
      'loads preferences from repository stream',
      build: () => NotificationPreferencesCubit(repository: repository),
      act: (_) {
        controller.add(
          const NotificationPreferencesEntity(
            scenarioChannels: {
              'musician_group_invite': {'push': false},
            },
            quietHours: QuietHoursConfig.defaults,
          ),
        );
      },
      expect: () => [
        isA<NotificationPreferencesState>()
            .having(
              (state) => state.status,
              'status',
              NotificationPreferencesStatus.success,
            )
            .having(
              (state) => state.entity.isChannelEnabled(
                NotificationScenario.musicianGroupInvite,
                NotificationChannel.push,
              ),
              'musicianGroupInvite.push',
              false,
            ),
      ],
    );

    blocTest<NotificationPreferencesCubit, NotificationPreferencesState>(
      'setScenarioChannel applies optimistic update and persists',
      build: () => NotificationPreferencesCubit(repository: repository),
      act: (cubit) async {
        controller.add(NotificationPreferencesEntity.defaults);
        await Future<void>.delayed(Duration.zero);
        await cubit.setScenarioChannel(
          NotificationScenario.musicianGroupInvite,
          NotificationChannel.push,
          false,
        );
      },
      expect: () => [
        isA<NotificationPreferencesState>()
            .having(
              (state) => state.status,
              'status',
              NotificationPreferencesStatus.success,
            )
            .having(
              (state) => state.entity.isChannelEnabled(
                NotificationScenario.musicianGroupInvite,
                NotificationChannel.push,
              ),
              'musicianGroupInvite.push',
              true,
            ),
        isA<NotificationPreferencesState>()
            .having(
              (state) => state.status,
              'status',
              NotificationPreferencesStatus.success,
            )
            .having(
              (state) => state.entity.isChannelEnabled(
                NotificationScenario.musicianGroupInvite,
                NotificationChannel.push,
              ),
              'musicianGroupInvite.push',
              false,
            ),
      ],
      verify: (_) {
        verify(
          () => repository.setScenarioChannel(
            NotificationScenario.musicianGroupInvite,
            NotificationChannel.push,
            false,
          ),
        ).called(1);
      },
    );

    blocTest<NotificationPreferencesCubit, NotificationPreferencesState>(
      'setScenarioChannel rolls back and emits failure when persistence fails',
      setUp: () {
        when(
          () => repository.setScenarioChannel(any(), any(), any()),
        ).thenThrow(Exception('write_failed'));
      },
      build: () => NotificationPreferencesCubit(repository: repository),
      act: (cubit) async {
        controller.add(NotificationPreferencesEntity.defaults);
        await Future<void>.delayed(Duration.zero);
        await cubit.setScenarioChannel(
          NotificationScenario.musicianGroupInvite,
          NotificationChannel.push,
          false,
        );
      },
      expect: () => [
        isA<NotificationPreferencesState>().having(
          (state) => state.status,
          'status',
          NotificationPreferencesStatus.success,
        ),
        isA<NotificationPreferencesState>()
            .having(
              (state) => state.status,
              'status',
              NotificationPreferencesStatus.success,
            )
            .having(
              (state) => state.entity.isChannelEnabled(
                NotificationScenario.musicianGroupInvite,
                NotificationChannel.push,
              ),
              'musicianGroupInvite.push',
              false,
            ),
        isA<NotificationPreferencesState>()
            .having(
              (state) => state.status,
              'status',
              NotificationPreferencesStatus.failure,
            )
            .having(
              (state) => state.entity.isChannelEnabled(
                NotificationScenario.musicianGroupInvite,
                NotificationChannel.push,
              ),
              'musicianGroupInvite.push',
              true,
            )
            .having(
              (state) => state.errorMessage,
              'errorMessage',
              contains('write_failed'),
            ),
      ],
    );
  });
}
