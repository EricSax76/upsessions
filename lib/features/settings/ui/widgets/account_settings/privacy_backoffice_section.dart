import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upsessions/core/widgets/app_card.dart';
import 'package:upsessions/features/settings/cubits/privacy_backoffice_state.dart';
import 'package:upsessions/features/settings/models/privacy_backoffice_request.dart';

class PrivacyBackofficeSection extends StatelessWidget {
  const PrivacyBackofficeSection({
    required this.state,
    required this.onFilterSelected,
    required this.onRefresh,
    required this.onStatusUpdateRequested,
    super.key,
  });

  final PrivacyBackofficeState state;
  final Future<void> Function(PrivacyRequestStatus? status) onFilterSelected;
  final Future<void> Function() onRefresh;
  final Future<void> Function(
    PrivacyBackofficeRequest request,
    PrivacyRequestStatus nextStatus,
  )
  onStatusUpdateRequested;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Backoffice de privacidad'),
            subtitle: const Text(
              'Gestiona estados operativos con trazabilidad.',
            ),
            trailing: IconButton(
              tooltip: 'Recargar',
              icon: const Icon(Icons.refresh),
              onPressed: state.isLoading
                  ? null
                  : () {
                      unawaited(onRefresh());
                    },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: state.selectedStatus == null,
                  onSelected: state.isLoading
                      ? null
                      : (selected) {
                          if (!selected) return;
                          unawaited(onFilterSelected(null));
                        },
                ),
                for (final status in privacyBackofficeFilterStatuses)
                  ChoiceChip(
                    label: Text(status.label),
                    selected: state.selectedStatus == status,
                    onSelected: state.isLoading
                        ? null
                        : (selected) {
                            if (!selected) return;
                            unawaited(onFilterSelected(status));
                          },
                  ),
              ],
            ),
          ),
          if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (!state.isLoading && state.requests.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('No hay solicitudes para el filtro actual.'),
            ),
          for (final request in state.requests) ...[
            const Divider(height: 1),
            _PrivacyBackofficeRequestTile(
              request: request,
              isBusy: state.isUpdatingStatus,
              isUpdatingThisRequest: state.activeRequestKey == request.key,
              onStatusUpdateRequested: onStatusUpdateRequested,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrivacyBackofficeRequestTile extends StatelessWidget {
  const _PrivacyBackofficeRequestTile({
    required this.request,
    required this.isBusy,
    required this.isUpdatingThisRequest,
    required this.onStatusUpdateRequested,
  });

  final PrivacyBackofficeRequest request;
  final bool isBusy;
  final bool isUpdatingThisRequest;
  final Future<void> Function(
    PrivacyBackofficeRequest request,
    PrivacyRequestStatus nextStatus,
  )
  onStatusUpdateRequested;

  @override
  Widget build(BuildContext context) {
    final status = request.status;
    final statusColor = _statusColor(context, status);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.requestTypeLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Chip(
                label: Text(request.statusLabel),
                backgroundColor: statusColor.withValues(alpha: 0.12),
                side: BorderSide(color: statusColor.withValues(alpha: 0.28)),
                labelStyle: TextStyle(color: statusColor),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Solicitud: ${request.requestId}'),
          Text('Usuario: ${request.userId}'),
          Text('Creada: ${_formatDateTime(request.createdAt)}'),
          if (request.reason != null) Text('Motivo usuario: ${request.reason}'),
          if (request.statusUpdatedAt != null ||
              request.statusUpdatedBy != null ||
              request.statusReason != null)
            Text(
              'Último cambio: ${_formatDateTime(request.statusUpdatedAt)}'
              '${request.statusUpdatedBy == null ? '' : ' · ${request.statusUpdatedBy}'}'
              '${request.statusReason == null ? '' : ' · ${request.statusReason}'}',
            ),
          if (request.allowedNextStatuses.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final nextStatus in request.allowedNextStatuses)
                  OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () {
                            unawaited(
                              onStatusUpdateRequested(request, nextStatus),
                            );
                          },
                    child: Text('Marcar ${nextStatus.label}'),
                  ),
              ],
            ),
          ],
          if (isUpdatingThisRequest) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      ),
    );
  }
}

Color _statusColor(BuildContext context, PrivacyRequestStatus? status) {
  final scheme = Theme.of(context).colorScheme;
  switch (status) {
    case PrivacyRequestStatus.pending:
      return scheme.tertiary;
    case PrivacyRequestStatus.inProgress:
      return scheme.primary;
    case PrivacyRequestStatus.completed:
      return scheme.secondary;
    case PrivacyRequestStatus.rejected:
      return scheme.error;
    case null:
      return scheme.outline;
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) return 'N/D';
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}
