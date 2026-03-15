import 'package:flutter/material.dart';

class NotificationCenterErrorView extends StatelessWidget {
  const NotificationCenterErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No pudimos cargar las notificaciones.\n$message',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
