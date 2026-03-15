import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/notification_preferences_cubit.dart';
import '../../cubits/notification_preferences_state.dart';
import '../../models/notification_scenario.dart';
import '../widgets/scenario_channel_tile.dart';

class NotificationPreferencesSection extends StatefulWidget {
  const NotificationPreferencesSection({super.key, required this.audience});

  final NotificationAudience? audience;

  @override
  State<NotificationPreferencesSection> createState() =>
      _NotificationPreferencesSectionState();
}

class _NotificationPreferencesSectionState
    extends State<NotificationPreferencesSection> {
  Future<void> _pickQuietRange() async {
    final cubit = context.read<NotificationPreferencesCubit>();
    final entity = cubit.state.entity;

    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: entity.quietStartHour, minute: 0),
      helpText: 'Hora de inicio',
    );
    if (!mounted || start == null) return;

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: entity.quietEndHour, minute: 0),
      helpText: 'Hora de fin',
    );
    if (!mounted || end == null) return;

    await cubit.setQuietRange(start.hour, end.hour);
  }

  @override
  Widget build(BuildContext context) {
    final audience = widget.audience;
    if (audience == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Este rol no tiene escenarios de notificaciones configurables.',
          ),
        ),
      );
    }

    final scenarios = scenariosForAudience(audience);
    return BlocBuilder<
      NotificationPreferencesCubit,
      NotificationPreferencesState
    >(
      builder: (context, state) {
        final entity = state.entity;
        final busy = state.status == NotificationPreferencesStatus.loading;
        final failing = state.status == NotificationPreferencesStatus.failure;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: entity.quietHoursEnabled,
                    title: const Text('Horas de silencio'),
                    subtitle: Text(
                      entity.quietHoursEnabled
                          ? 'Silenciar de ${_hourLabel(entity.quietStartHour)} a ${_hourLabel(entity.quietEndHour)}'
                          : 'Desactivadas',
                    ),
                    onChanged: (_) => context
                        .read<NotificationPreferencesCubit>()
                        .toggleQuietHours(),
                  ),
                  ListTile(
                    enabled: entity.quietHoursEnabled,
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('Rango horario'),
                    subtitle: Text(
                      '${_hourLabel(entity.quietStartHour)} - ${_hourLabel(entity.quietEndHour)}',
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: entity.quietHoursEnabled ? _pickQuietRange : null,
                  ),
                  if (busy) const LinearProgressIndicator(minHeight: 2),
                ],
              ),
            ),
            if (failing) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'No se pudo guardar la preferencia.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            for (final scenario in scenarios) ...[
              ScenarioChannelTile(
                scenario: scenario,
                entity: entity,
                onChannelChanged: context
                    .read<NotificationPreferencesCubit>()
                    .setScenarioChannel,
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

String _hourLabel(int hour) => '${hour.toString().padLeft(2, '0')}:00';
