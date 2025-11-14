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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final (icon, label) in actions)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(icon),
                label: Text(label, textAlign: TextAlign.center),
              ),
            ),
          ),
      ],
    );
  }
}
