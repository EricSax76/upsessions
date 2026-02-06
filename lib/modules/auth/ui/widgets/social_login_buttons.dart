import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gap.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key, required this.onSelected});

  final void Function(String provider) onSelected;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    String tooltip(String label) => localization.continueWithProvider(label);
    final providers = [
      _SocialProvider(
        icon: Icons.g_mobiledata,
        label: localization.providerGoogle,
      ),
      _SocialProvider(
        icon: Icons.facebook_outlined,
        label: localization.providerFacebook,
      ),
      _SocialProvider(
        icon: Icons.apple,
        label: localization.providerApple,
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < providers.length; i++) ...[
          if (i > 0) const HSpace(AppSpacing.sm),
          Expanded(
            child: _SocialButton(
              icon: providers[i].icon,
              label: providers[i].label,
              tooltip: tooltip(providers[i].label),
              onPressed: () => onSelected(providers[i].label),
            ),
          ),
        ],
      ],
    );
  }
}

class _SocialProvider {
  const _SocialProvider({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 56,
      child: Tooltip(
        message: tooltip,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: AppSpacing.sm,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
