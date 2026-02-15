import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/profile/cubit/profile_form_cubit.dart';
import 'profile_affinity_input.dart';

class ProfileAffinitySection extends StatelessWidget {
  const ProfileAffinitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Afinidades musicales',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Agrega o quita artistas que representen tus influencias por estilo.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        const ProfileAffinityInput(),
        const SizedBox(height: 16),
        BlocBuilder<ProfileFormCubit, ProfileFormState>(
          builder: (context, state) {
            if (state.influences.isEmpty) {
              return Text(
                'Sin afinidades registradas.',
                style: Theme.of(context).textTheme.bodyMedium,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildInfluenceList(context, state),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildInfluenceList(
    BuildContext context,
    ProfileFormState state,
  ) {
    final cubit = context.read<ProfileFormCubit>();
    final entries =
        state.influences.entries.toList()
          ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return entries.map((entry) {
      final style = entry.key;
      final artists = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              style,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  artists
                      .map(
                        (artist) => Chip(
                          label: Text(artist),
                          onDeleted: () => cubit.removeInfluence(style, artist),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      );
    }).toList();
  }
}
