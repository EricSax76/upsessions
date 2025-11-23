import 'package:flutter/material.dart';

class ProfileStatusBar extends StatelessWidget {
  const ProfileStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final avatar = const CircleAvatar(
          radius: 24,
          child: Icon(Icons.person),
        );
        final info = const Expanded(child: _ProfileInfo());
        final editButton = FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit),
          label: const Text('Actualizar perfil'),
        );

        final rowChildren = <Widget>[
          avatar,
          const SizedBox(width: 16),
          info,
          editButton,
        ];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: rowChildren.take(3).toList()),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: editButton),
                  ],
                )
              : Row(children: rowChildren),
        );
      },
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Solista Demo', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Voz principal | Disponible para giras'),
      ],
    );
  }
}
