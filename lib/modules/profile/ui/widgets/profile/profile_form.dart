import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/constants/music_styles.dart';
import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/profile/cubit/profile_form_cubit.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key, required this.profile, required this.onSave});

  final ProfileEntity profile;
  final ValueChanged<ProfileEntity> onSave;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileFormCubit(profile: profile),
      child: BlocBuilder<ProfileFormCubit, ProfileFormState>(
        builder: (context, state) {
          final cubit = context.read<ProfileFormCubit>();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: state.bio,
                  decoration: const InputDecoration(labelText: 'Biografía'),
                  maxLines: 4,
                  onChanged: cubit.bioChanged,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: state.location,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                  onChanged: cubit.locationChanged,
                ),
                const SizedBox(height: 24),
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
                _InfluenceInputs(),
                const SizedBox(height: 16),
                if (state.influences.isEmpty)
                  Text(
                    'Sin afinidades registradas.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildInfluenceList(context, state, cubit),
                  ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => onSave(cubit.getUpdatedProfile(profile)),
                    child: const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildInfluenceList(
      BuildContext context, ProfileFormState state, ProfileFormCubit cubit) {
    final entries = state.influences.entries.toList()
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
              children: artists
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

class _InfluenceInputs extends StatefulWidget {
  @override
  State<_InfluenceInputs> createState() => _InfluenceInputsState();
}

class _InfluenceInputsState extends State<_InfluenceInputs> {
  late TextEditingController _artistController;

  @override
  void initState() {
    super.initState();
    _artistController = TextEditingController();
  }

  @override
  void dispose() {
    _artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileFormCubit, ProfileFormState>(
      listenWhen: (previous, current) => previous.selectedStyle != current.selectedStyle,
      listener: (context, state) {
        _artistController.clear();
      },
      builder: (context, state) {
        final cubit = context.read<ProfileFormCubit>();
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 640;
            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   DropdownButtonFormField<String>(
                    value: state.selectedStyle,
                    decoration: const InputDecoration(labelText: 'Estilo'),
                    items: musicStyles
                        .map(
                          (style) =>
                              DropdownMenuItem(value: style, child: Text(style)),
                        )
                        .toList(),
                    onChanged: cubit.styleChanged,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _artistController,
                    decoration: const InputDecoration(labelText: 'Artista / Banda'),
                    onSubmitted: (_) { 
                      cubit.addInfluence(_artistController.text);
                      _artistController.clear();
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () {
                         cubit.addInfluence(_artistController.text);
                         _artistController.clear();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                    ),
                  ),
                  _SuggestedOptions(controller: _artistController),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: state.selectedStyle,
                        decoration: const InputDecoration(labelText: 'Estilo'),
                        items: musicStyles
                            .map(
                              (style) => DropdownMenuItem(
                                value: style,
                                child: Text(style, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: cubit.styleChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _artistController,
                        decoration: const InputDecoration(
                          labelText: 'Artista / Banda',
                        ),
                        onSubmitted: (_) {
                          cubit.addInfluence(_artistController.text);
                          _artistController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () {
                        cubit.addInfluence(_artistController.text);
                        _artistController.clear();
                      },
                      icon: const Icon(Icons.add),
                      tooltip: 'Agregar afinidad',
                    ),
                  ],
                ),
                _SuggestedOptions(controller: _artistController),
              ],
            );
          },
        );
      },
    );
  }
}

class _SuggestedOptions extends StatelessWidget {
  const _SuggestedOptions({required this.controller});
  
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
      return BlocBuilder<ProfileFormCubit, ProfileFormState>(
        builder: (context, state) {
           if (state.selectedStyle == null) return const SizedBox.shrink();

           final cubit = context.read<ProfileFormCubit>();
           
           // Filter suggestions based on input if needed, or show all
           // Here we show all and let the user pick
           final suggestions = state.suggestedArtists; // Simplified for now
          
           // Re-implement client side filtering for suggestion based on text field if desired
           // For now, we just rely on what is in state.suggestedArtists

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const SizedBox(height: 12),
                Text(
                  'Opciones sugeridas',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                if (state.isLoadingSuggestions)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (suggestions.isEmpty)
                   Text(
                    'Sin coincidencias para este estilo.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                   Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions
                        .map(
                          (artist) => FilterChip(
                            label: Text(artist),
                            selected: _isArtistSelected(state.influences, state.selectedStyle!, artist),
                            onSelected: (selected) {
                              if (selected) {
                                cubit.addInfluence(artist);
                              } else {
                                cubit.removeInfluence(state.selectedStyle!, artist);
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
             ],
           );
        },
      );
  }

  bool _isArtistSelected(Map<String, List<String>> influences, String style, String artist) {
    final artists = influences[style] ?? const <String>[];
    return artists.any(
      (current) => current.toLowerCase() == artist.toLowerCase(),
    );
  }
}
