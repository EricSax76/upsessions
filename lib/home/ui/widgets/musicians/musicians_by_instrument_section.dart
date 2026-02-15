import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/user_home_cubit.dart';
import '../../../cubits/user_home_state.dart';
import '../../../models/instrument_category_model.dart';
import '../../../../modules/musicians/models/musician_entity.dart';
import 'musicians_grid.dart';

class MusiciansByInstrumentSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocBuilder<UserHomeCubit, UserHomeState>(
      buildWhen: (previous, current) => previous.instrument != current.instrument,
      builder: (context, state) {
        final selectedInstrument = state.instrument; // Assuming 'instrument' field exists in UserHomeState
        // If it doesn't exist, I need to check UserHomeState definition.
        // In Step 1137, selectInstrument updates 'instrument'. So it exists.
        
        final chips = <Widget>[];
        for (final category in categories) {
          chips.add(
            Text(category.category, style: Theme.of(context).textTheme.titleSmall),
          );
          chips.addAll(
            category.instruments.map(
              (instrument) => Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 4),
                child: ChoiceChip(
                  label: Text(instrument),
                  selected: selectedInstrument == instrument,
                  onSelected: (selected) {
                    onInstrumentSelected(selected ? instrument : '');
                  },
                ),
              ),
            ),
          );
        }

        final filtered = selectedInstrument.isEmpty
            ? musicians
            : musicians
                .where((m) => m.instrument == selectedInstrument)
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(children: chips),
            const SizedBox(height: 12),
            MusiciansGrid(musicians: filtered),
          ],
        );
      },
    );
  }
}
