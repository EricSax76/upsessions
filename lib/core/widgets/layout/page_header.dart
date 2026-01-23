import 'package:flutter/material.dart';

import '../section_title.dart';

/// Header de página con título, subtítulo y acciones opcionales.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    this.actions = const [],
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final String? subtitle;
  final String? badge;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: SectionHeader(
              title: title,
              subtitle: subtitle,
              label: badge,
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: 12),
            ...actions,
          ],
        ],
      ),
    );
  }
}
