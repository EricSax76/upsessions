import 'package:flutter/material.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_box_outlined, 'Nuevo anuncio'),
      (Icons.campaign_outlined, 'Promocionar show'),
      (Icons.calendar_today_outlined, 'Agendar evento'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final buttons = actions
            .map(
              (entry) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 0 : 4,
                  vertical: isCompact ? 4 : 0,
                ),
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(entry.$1),
                  label: Text(entry.$2, textAlign: TextAlign.center),
                ),
              ),
            )
            .toList();

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buttons,
          );
        }

        return Row(
          children: [for (final button in buttons) Expanded(child: button)],
        );
      },
    );
  }
}
