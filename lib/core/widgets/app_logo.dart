import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'gap.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.label, this.textStyle, this.iconSize});

  final String label;
  final TextStyle? textStyle;
  final double? iconSize;

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
            size: iconSize ?? 28,
            color: theme.colorScheme.primary,
          ),
          const HSpace(AppSpacing.sm),
          Text(
            label,
            style: textStyle ?? theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
