import 'package:flutter/material.dart';

import '../../../../core/widgets/stat_card.dart';

class GlobalStatsRow extends StatelessWidget {
  const GlobalStatsRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final stats = const <StatCard>[];

        if (isCompact) {
          return Column(
            children: [
              for (final card in stats) ...[card, const SizedBox(height: 12)],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              Expanded(child: stats[i]),
              if (i < stats.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }
}


