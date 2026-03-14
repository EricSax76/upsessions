import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../models/jam_session_entity.dart';

class JamSessionListTile extends StatelessWidget {
  const JamSessionListTile({super.key, required this.session});

  final JamSessionEntity session;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
          image: session.coverImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(session.coverImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: session.coverImageUrl == null
            ? Icon(
                Icons.music_note,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              )
            : null,
      ),
      title: Text(
        session.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${session.city} • ${_formatDate(session.date)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(
        AppRoutes.eventManagerJamSessionDetailPath(session.id),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Por definir';
    return '${date.day}/${date.month}/${date.year}';
  }
}
