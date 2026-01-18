import 'package:flutter/material.dart';

import '../../../models/instrument_category_model.dart';
import '../../../../modules/musicians/models/musician_entity.dart';
import 'musicians_grid.dart';

class MusiciansByInstrumentSection extends StatefulWidget {
  const MusiciansByInstrumentSection({
    super.key,
    required this.categories,
    required this.musicians,
    required this.onInstrumentSelected,
  });

  final List<InstrumentCategoryModel> categories;
  final List<MusicianEntity> musicians;
  final ValueChanged<String> onInstrumentSelected;

  @override
  State<MusiciansByInstrumentSection> createState() =>
      _MusiciansByInstrumentSectionState();
}

class _MusiciansByInstrumentSectionState
    extends State<MusiciansByInstrumentSection> {
  String? _selectedInstrument;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final category in widget.categories) {
      chips.add(
        Text(category.category, style: Theme.of(context).textTheme.titleSmall),
      );
      chips.addAll(
        category.instruments.map(
          (instrument) => Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 4),
            child: ChoiceChip(
              label: Text(instrument),
              selected: _selectedInstrument == instrument,
              onSelected: (_) {
                setState(() => _selectedInstrument = instrument);
                widget.onInstrumentSelected(instrument);
              },
            ),
          ),
        ),
      );
    }

    final filtered = _selectedInstrument == null
        ? widget.musicians
        : widget.musicians
              .where((m) => m.instrument == _selectedInstrument)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(children: chips),
        const SizedBox(height: 12),
        MusiciansGrid(musicians: filtered),
      ],
    );
  }
}
