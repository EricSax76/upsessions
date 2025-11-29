import 'package:flutter/material.dart';

import '../../../../../core/constants/app_routes.dart';

class MusiciansTab extends StatelessWidget {
  const MusiciansTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _TabPlaceholder(
      icon: Icons.people_outline,
      title: 'Músicos',
      description: 'Explora y encuentra músicos por estilo, instrumento o ubicación.',
      actionLabel: 'Ir a músicos',
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.musicians),
    );
  }
}

class AnnouncementsTab extends StatelessWidget {
  const AnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _TabPlaceholder(
      icon: Icons.campaign_outlined,
      title: 'Anuncios',
      description: 'Publica o revisa anuncios recientes.',
      actionLabel: 'Ver anuncios',
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.announcements),
    );
  }
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _TabPlaceholder(
      icon: Icons.chat_bubble_outline,
      title: 'Mensajes',
      description: 'Revisa tus conversaciones con otros músicos.',
      actionLabel: 'Abrir mensajes',
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.chat),
    );
  }
}

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TabPlaceholder(
      icon: Icons.event_available_outlined,
      title: 'Eventos',
      description: 'Descubre los próximos eventos de la semana.',
      actionLabel: 'Explorar eventos',
      onPressed: null,
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
