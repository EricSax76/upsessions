import 'package:flutter/material.dart';
import '../../../../../modules/events/models/event_entity.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_routes.dart';

class ManagerEventCard extends StatelessWidget {
  const ManagerEventCard({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          image: event.bannerImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(event.bannerImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: event.bannerImageUrl == null ? const Icon(Icons.event) : null,
      ),
      title: Text(
        event.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${event.city} • ${_formatDate(event.start)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          context.push(AppRoutes.eventManagerEventDetailPath(event.id)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
