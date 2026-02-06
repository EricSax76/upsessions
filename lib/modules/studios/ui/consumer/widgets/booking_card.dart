import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/booking_entity.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  final BookingEntity booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isConfirmed = booking.status == BookingStatus.confirmed;

    Color statusColor;
    Color statusOnColor;
    String statusText;

    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = scheme.primaryContainer;
        statusOnColor = scheme.onPrimaryContainer;
        statusText = 'CONFIRMADA';
        break;
      case BookingStatus.cancelled:
        statusColor = scheme.errorContainer;
        statusOnColor = scheme.onErrorContainer;
        statusText = 'CANCELADA';
        break;
      case BookingStatus.pending:
        statusColor = scheme.surfaceContainerHighest;
        statusOnColor = scheme.onSurfaceVariant;
        statusText = 'PENDIENTE';
        break;
    }

    final timeFormat = DateFormat('HH:mm');

    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: scheme.surface, // Or strictly surfaceContainerLow for more depth
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Box - sleek vertical design
                  Container(
                    width: 56,
                    height: 64,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d').format(booking.startTime),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM').format(booking.startTime).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Main Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.studioName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.roomName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge (Pill)
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusOnColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isConfirmed) ...[
                           Icon(Icons.check_circle, size: 12, color: statusOnColor),
                           const SizedBox(width: 4),
                        ],
                        Text(
                          statusText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusOnColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Footer: Time & Price & ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                 decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_filled, size: 16, color: scheme.secondary),
                    const SizedBox(width: 6),
                    Text(
                      '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const VerticalDivider(width: 24, thickness: 1), // Only visible if height set, hacks spacer
                     Container(
                      width: 1, 
                      height: 12, 
                      color: scheme.outlineVariant, 
                      margin: const EdgeInsets.symmetric(horizontal: 12)
                    ),
                    Text(
                      '${booking.totalPrice.toStringAsFixed(0)}€',
                       style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '#${booking.id.substring(0, 6)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
