import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';

class ProfileQuickActionsFab extends StatefulWidget {
  const ProfileQuickActionsFab({super.key});

  @override
  State<ProfileQuickActionsFab> createState() => _ProfileQuickActionsFabState();
}

class _ProfileQuickActionsFabState extends State<ProfileQuickActionsFab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'profile-quick-actions-fab',
      onPressed: () => _openQuickActionsModal(context),
      child: const Icon(Icons.add),
    );
  }

  void _openQuickActionsModal(BuildContext context) {
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Acciones rápidas'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FabActionButton(
                icon: Icons.post_add_outlined,
                label: 'Nuevo anuncio',
                onPressed: () {
                  navigator.pop(); // cierra el modal
                  _onAction(() => context.push(AppRoutes.announcements));
                },
              ),
              const SizedBox(height: 12),
              _FabActionButton(
                icon: Icons.campaign_outlined,
                label: 'Promocionar show',
                onPressed: () {
                  navigator.pop();
                  _onAction(() => _showSnack(context));
                },
              ),
              const SizedBox(height: 12),
              _FabActionButton(
                icon: Icons.event_outlined,
                label: 'Agendar evento',
                onPressed: () {
                  navigator.pop();
                  _onAction(() => _showSnack(context));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onAction(VoidCallback action) {
    // Aquí ya no gestionamos _isOpen ni nada, solo ejecutamos la acción
    action();
  }

  void _showSnack(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Próximamente')));
  }
}

class _FabActionButton extends StatelessWidget {
  const _FabActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: theme.colorScheme.primary),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          foregroundColor: theme.colorScheme.primary,
          shape: const StadiumBorder(),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
      ),
    );
  }
}
