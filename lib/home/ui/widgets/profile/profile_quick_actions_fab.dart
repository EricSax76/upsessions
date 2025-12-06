import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';

class ProfileQuickActionsFab extends StatefulWidget {
  const ProfileQuickActionsFab({super.key});

  @override
  State<ProfileQuickActionsFab> createState() => _ProfileQuickActionsFabState();
}

class _ProfileQuickActionsFabState extends State<ProfileQuickActionsFab> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _FabActionButton(
        icon: Icons.post_add_outlined,
        label: 'Nuevo anuncio',
        onPressed: () => _onAction(() => context.push(AppRoutes.announcements)),
      ),
      _FabActionButton(
        icon: Icons.campaign_outlined,
        label: 'Promocionar show',
        onPressed: () => _onAction(() => _showSnack(context)),
      ),
      _FabActionButton(
        icon: Icons.event_outlined,
        label: 'Agendar evento',
        onPressed: () => _onAction(() => _showSnack(context)),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            ),
          ),
          child: !_isOpen
              ? const SizedBox.shrink()
              : Column(
                  key: const ValueKey('fab-actions'),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final action in actions) ...[
                      action,
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
        FloatingActionButton(
          onPressed: _toggle,
          child: Icon(_isOpen ? Icons.close : Icons.add),
        ),
      ],
    );
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
  }

  void _onAction(VoidCallback action) {
    setState(() => _isOpen = false);
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
