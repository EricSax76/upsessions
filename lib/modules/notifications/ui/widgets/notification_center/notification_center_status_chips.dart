import 'package:flutter/material.dart';

import '../../../../event_manager/models/musician_request_entity.dart';

class StudioStatusChip extends StatelessWidget {
  const StudioStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (status) {
      'confirmed' => (
        'Confirmada',
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      'cancelled' || 'refunded' => (
        'Cancelada',
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      _ => (
        'Pendiente',
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
    };

    return _StatusChip(
      label: label,
      background: background,
      foreground: foreground,
    );
  }
}

class ManagerStatusChip extends StatelessWidget {
  const ManagerStatusChip({super.key, required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (status) {
      RequestStatus.accepted => (
        'Aceptada',
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      RequestStatus.rejected => (
        'Rechazada',
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      RequestStatus.pending => (
        'Pendiente',
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
    };

    return _StatusChip(
      label: label,
      background: background,
      foreground: foreground,
    );
  }
}

class VenueVisibilityChip extends StatelessWidget {
  const VenueVisibilityChip({
    super.key,
    required this.isCanceled,
    required this.isPublic,
  });

  final bool isCanceled;
  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    if (isCanceled) {
      return const _StatusChip(
        label: 'Cancelada',
        background: null,
        foreground: null,
      );
    }

    if (isPublic) return const SizedBox.shrink();

    return const _StatusChip(
      label: 'Privada',
      background: null,
      foreground: null,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 11, color: foreground)),
      backgroundColor: background,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
