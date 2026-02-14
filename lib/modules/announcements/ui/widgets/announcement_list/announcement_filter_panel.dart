import 'package:flutter/material.dart';

enum AnnouncementUiFilter { all, nearby, urgent }

class AnnouncementFilterPanel extends StatefulWidget {
  const AnnouncementFilterPanel({super.key, required this.onChanged});

  final ValueChanged<AnnouncementUiFilter> onChanged;

  @override
  State<AnnouncementFilterPanel> createState() =>
      _AnnouncementFilterPanelState();
}

class _AnnouncementFilterPanelState extends State<AnnouncementFilterPanel> {
  AnnouncementUiFilter _selected = AnnouncementUiFilter.all;
  final filters = const <(AnnouncementUiFilter, String)>[
    (AnnouncementUiFilter.all, 'Todos'),
    (AnnouncementUiFilter.nearby, 'Cercanos'),
    (AnnouncementUiFilter.urgent, 'Urgentes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: filters
          .map(
            (filter) => ChoiceChip(
              label: Text(filter.$2),
              selected: _selected == filter.$1,
              onSelected: (_) {
                setState(() => _selected = filter.$1);
                widget.onChanged(filter.$1);
              },
            ),
          )
          .toList(),
    );
  }
}
