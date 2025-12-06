import 'package:flutter/material.dart';

class MusicianFiltersChipRow extends StatefulWidget {
  const MusicianFiltersChipRow({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<MusicianFiltersChipRow> createState() => _MusicianFiltersChipRowState();
}

class _MusicianFiltersChipRowState extends State<MusicianFiltersChipRow> {
  String? _selected;
  final _filters = const ['Disponible', 'Con experiencia', 'Acepta giras'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final filter in _filters)
          ChoiceChip(
            label: Text(filter),
            selected: _selected == filter,
            onSelected: (_) {
              setState(() => _selected = filter);
              widget.onChanged(filter);
            },
          ),
      ],
    );
  }
}
