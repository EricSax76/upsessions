import 'package:flutter/material.dart';

class ProfileLinkBox extends StatelessWidget {
  const ProfileLinkBox({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final copyButton = TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.copy),
          label: const Text('Copiar enlace'),
        );
        final linkText = const Text(
          'Comparte tu perfil: solomusicos.app/solista-demo',
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link),
                        const SizedBox(width: 12),
                        Expanded(child: linkText),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: copyButton),
                  ],
                )
              : Row(
                  children: [
                    const Icon(Icons.link),
                    const SizedBox(width: 12),
                    Expanded(child: linkText),
                    copyButton,
                  ],
                ),
        );
      },
    );
  }
}
