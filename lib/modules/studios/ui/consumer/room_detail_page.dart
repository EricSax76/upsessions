import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../cubits/booking_cubit.dart';
import '../../models/room_entity.dart';
import 'rehearsal_booking_context.dart';
import 'room_booking_dialog.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../repositories/studios_repository.dart';
import '../../../rehearsals/repositories/rehearsals_repository.dart';
import '../../../../core/locator/locator.dart';

class RoomDetailPage extends StatelessWidget {
  const RoomDetailPage({
    super.key,
    required this.room,
    required this.studioName,
    this.rehearsalContext,
  });

  final RoomEntity room;
  final String studioName;
  final RehearsalBookingContext? rehearsalContext;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for image
              Container(
                height: 200,
                width: double.infinity,
                color: theme.colorScheme.surfaceContainerHighest,
                child: room.photos.isNotEmpty
                    ? Image.network(
                        room.photos.first,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.broken_image_outlined,
                          size: 50,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(
                        Icons.image,
                        size: 50,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(height: 16),
              Text(room.name, style: theme.textTheme.headlineMedium),
              Text(
                loc.roomDetailPricePerHour(
                  room.pricePerHour.toStringAsFixed(2),
                ),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.people,
                loc.roomDetailCapacity(room.capacity),
              ),
              _buildInfoRow(
                context,
                Icons.square_foot,
                loc.roomDetailSize(room.size),
              ),
              // ── Normativa ──────────────────────────────
              _buildInfoRow(
                context,
                Icons.timer,
                loc.roomDetailMinBookingHours(room.minBookingHours),
              ),
              if (room.maxDecibels != null)
                _buildInfoRow(
                  context,
                  Icons.volume_up,
                  loc.roomDetailMaxDecibels(
                    room.maxDecibels!.toStringAsFixed(1),
                  ),
                ),
              if (room.ageRestriction != null)
                _buildInfoRow(
                  context,
                  Icons.person,
                  loc.roomDetailMinimumAge(room.ageRestriction!),
                ),
              if (room.isAccessible)
                _buildInfoRow(
                  context,
                  Icons.accessible,
                  loc.roomDetailAccessibleMobility,
                ),
              if (room.cancellationPolicy != null) ...[
                const SizedBox(height: 16),
                Text(
                  loc.roomDetailCancellationPolicyTitle,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  room.cancellationPolicy!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                loc.roomDetailEquipmentTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: room.equipment
                    .map((e) => Chip(label: Text(e)))
                    .toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _showBookingDialog(context),
                  child: Text(
                    rehearsalContext != null
                        ? loc.roomDetailBookForRehearsal
                        : loc.roomDetailBookRoom,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (context) => BookingCubit(
          roomPricePerHour: room.pricePerHour,
          roomId: room.id,
          roomName: room.name,
          studioId: room.studioId,
          studioName: studioName,
          rehearsalContext: rehearsalContext,
          authRepository: locate<AuthRepository>(),
          studiosRepository: locate<StudiosRepository>(),
          rehearsalsRepository: locate<RehearsalsRepository>(),
        ),
        child: const RoomBookingDialog(),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
