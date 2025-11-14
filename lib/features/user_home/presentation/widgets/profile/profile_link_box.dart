import 'package:flutter/material.dart';

class ProfileLinkBox extends StatelessWidget {
  const ProfileLinkBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.link),
          const SizedBox(width: 12),
          const Expanded(child: Text('Comparte tu perfil: solomusicos.app/solista-demo')),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.copy), label: const Text('Copiar enlace')),
        ],
      ),
    );
  }
}
