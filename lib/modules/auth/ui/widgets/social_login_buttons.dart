import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key, required this.onSelected});

  final void Function(String provider) onSelected;

  @override
  Widget build(BuildContext context) {
    final providers = [
      (Icons.mail_outline_rounded, 'Email'),
      (Icons.facebook_outlined, 'Facebook'),
      (Icons.apple, 'Apple'),
    ];
    return Row(
      children: [
        for (var i = 0; i < providers.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(
            child: _SocialButton(
              icon: providers[i].$1,
              label: providers[i].$2,
              onPressed: () => onSelected(providers[i].$2),
            ),
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Tooltip(
        message: 'Continuar con $label',
        child: OutlinedButton(onPressed: onPressed, child: Icon(icon)),
      ),
    );
  }
}
