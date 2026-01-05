import 'package:flutter/material.dart';

class AccountMissingProfileView extends StatelessWidget {
  const AccountMissingProfileView({
    super.key,
    required this.isLoading,
    required this.onRetry,
    required this.onSignOut,
    this.error,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64),
            const SizedBox(height: 16),
            Text(
              error ?? 'No pudimos cargar tu perfil en este momento.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            TextButton(
              onPressed: onSignOut,
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
