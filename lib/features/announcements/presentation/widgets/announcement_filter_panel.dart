import 'package:flutter/material.dart';

class AnnouncementFilterPanel extends StatefulWidget {
  const AnnouncementFilterPanel({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<AnnouncementFilterPanel> createState() => _AnnouncementFilterPanelState();
}

class _AnnouncementFilterPanelState extends State<AnnouncementFilterPanel> {
  String? _selected;
  final filters = const ['Todos', 'Cercanos', 'Urgentes'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: filters
          .map(
            (filter) => ChoiceChip(
              label: Text(filter),
              selected: _selected == filter,
              onSelected: (_) {
                setState(() => _selected = filter);
                widget.onChanged(filter);
              },
            ),
          )
          .toList(),
    );
  }
}
