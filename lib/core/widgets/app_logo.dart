import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'gap.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 28,
            color: theme.colorScheme.primary,
          ),
          const HSpace(AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
