import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/constants/music_styles.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/musicians/application/affinity_flow.dart';
import 'package:upsessions/modules/profile/cubit/profile_form_cubit.dart';

class ProfileAffinityInput extends StatefulWidget {
  const ProfileAffinityInput({super.key});

  @override
  State<ProfileAffinityInput> createState() => _ProfileAffinityInputState();
}

class _ProfileAffinityInputState extends State<ProfileAffinityInput> {
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

  void _submitArtist(ProfileFormCubit cubit) {
    cubit.addInfluence(_artistController.text);
    _artistController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<ProfileFormCubit, ProfileFormState>(
      listenWhen: (previous, current) =>
          previous.selectedStyle != current.selectedStyle,
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
                    initialValue: state.selectedStyle,
                    decoration: InputDecoration(
                      labelText: loc.affinityStyleLabel,
                    ),
                    items: musicStyles
                        .map(
                          (style) => DropdownMenuItem(
                            value: style,
                            child: Text(style),
                          ),
                        )
                        .toList(),
                    onChanged: cubit.styleChanged,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _artistController,
                    decoration: InputDecoration(
                      labelText: loc.affinityArtistBandLabel,
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submitArtist(cubit),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => _submitArtist(cubit),
                      icon: const Icon(Icons.add),
                      label: Text(loc.affinityAddButton),
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
                        initialValue: state.selectedStyle,
                        decoration: InputDecoration(
                          labelText: loc.affinityStyleLabel,
                        ),
                        items: musicStyles
                            .map(
                              (style) => DropdownMenuItem(
                                value: style,
                                child: Text(
                                  style,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                        decoration: InputDecoration(
                          labelText: loc.affinityArtistBandLabel,
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _submitArtist(cubit),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _submitArtist(cubit),
                      icon: const Icon(Icons.add),
                      tooltip: loc.affinityAddTooltip,
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
        final loc = AppLocalizations.of(context);

        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final suggestions = AffinityFlow.filterSuggestions(
              suggestions: state.suggestedArtists,
              query: value.text,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  loc.affinitySuggestedOptionsLabel,
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
                    loc.affinityNoMatchesForStyle,
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
                            selected: AffinityFlow.isArtistSelected(
                              influences: state.influences,
                              style: state.selectedStyle!,
                              artist: artist,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                cubit.addInfluence(artist);
                                return;
                              }
                              cubit.removeInfluence(
                                state.selectedStyle!,
                                artist,
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
