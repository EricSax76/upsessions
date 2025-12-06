import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key, required this.onSelected});

  final void Function(String provider) onSelected;

  @override
  Widget build(BuildContext context) {
    final providers = [
      (Icons.mail_outline, 'Google'),
      (Icons.facebook_outlined, 'Facebook'),
      (Icons.apple, 'Apple'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (icon, name) in providers)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              onPressed: () => onSelected(name),
              icon: Icon(icon),
              tooltip: 'Continuar con $name',
            ),
          ),
      ],
    );
  }
}
