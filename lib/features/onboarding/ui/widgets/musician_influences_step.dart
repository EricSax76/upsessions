import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/musicians/application/affinity_flow.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';

import '../../../../modules/musicians/repositories/affinity_options_repository.dart';
import '../../../../modules/musicians/repositories/artist_image_repository.dart';
import '../../cubits/musician_onboarding_cubit.dart';
import '../../cubits/musician_onboarding_state.dart';
import 'musician_influences_input_row.dart';
import 'musician_influences_selected_list.dart';
import 'musician_influences_suggestions.dart';
import 'musician_onboarding_step_card.dart';

class MusicianInfluencesStep extends StatefulWidget {
  const MusicianInfluencesStep({
    super.key,
    required this.formKey,
    required this.cubit,
    required this.affinityOptionsRepository,
    required this.artistImageRepository,
  });

  final GlobalKey<FormState> formKey;
  final MusicianOnboardingCubit cubit;
  final AffinityOptionsRepository affinityOptionsRepository;
  final ArtistImageRepository artistImageRepository;

  @override
  State<MusicianInfluencesStep> createState() => _MusicianInfluencesStepState();
}

class _MusicianInfluencesStepState extends State<MusicianInfluencesStep> {
  final _artistController = TextEditingController();
  String? _selectedStyle;
  List<String> _styleArtistOptions = const [];
  bool _loadingStyleOptions = false;
  Map<String, ArtistImageInfo> _artistImagesByName = const {};
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    final initialArtists = widget.cubit.state.influences.values
        .expand((artists) => artists)
        .where((artist) => artist.trim().isNotEmpty)
        .toSet();
    if (initialArtists.isEmpty) {
      return;
    }
    unawaited(
      _loadArtistImages(initialArtists, requestId: _loadRequestId, merge: true),
    );
  }

  @override
  void dispose() {
    _artistController.dispose();
    super.dispose();
  }

  void _addInfluence({String? artistName}) {
    final style = _selectedStyle;
    final artist = (artistName ?? _artistController.text).trim();
    if (artist.isEmpty || style == null) {
      return;
    }

    widget.cubit.addInfluence(style, artist);
    setState(() {
      _artistController.clear();
    });
    unawaited(
      _loadArtistImages([artist], requestId: _loadRequestId, merge: true),
    );
  }

  List<String> _suggestedArtists() {
    final style = _selectedStyle;
    if (style == null) return const [];

    final options = _styleArtistOptions;
    if (options.isEmpty) return const [];

    return AffinityFlow.filterSuggestions(
      suggestions: options,
      query: _artistController.text,
    );
  }

  Future<void> _loadArtistImages(
    Iterable<String> artists, {
    required int requestId,
    bool merge = false,
  }) async {
    final resolved = await widget.artistImageRepository.resolveArtists(artists);
    if (!mounted || requestId != _loadRequestId) {
      return;
    }

    setState(() {
      if (merge) {
        final updated = Map<String, ArtistImageInfo>.from(_artistImagesByName);
        updated.addAll(resolved);
        _artistImagesByName = updated;
      } else {
        _artistImagesByName = resolved;
      }
    });
  }

  Future<void> _onStyleChanged(String? style) async {
    final normalized = style?.trim();
    if (!mounted) return;

    if (normalized == null || normalized.isEmpty) {
      _loadRequestId++;
      setState(() {
        _selectedStyle = null;
        _artistController.clear();
        _styleArtistOptions = const [];
        _artistImagesByName = const {};
        _loadingStyleOptions = false;
      });
      return;
    }

    final requestId = ++_loadRequestId;
    setState(() {
      _selectedStyle = normalized;
      _artistController.clear();
      _styleArtistOptions = const [];
      _artistImagesByName = const {};
      _loadingStyleOptions = true;
    });

    final remoteOrFallback = await widget.affinityOptionsRepository
        .fetchArtistOptionsForStyle(normalized);
    if (!mounted || requestId != _loadRequestId) return;

    setState(() {
      _styleArtistOptions = remoteOrFallback;
      _loadingStyleOptions = false;
    });

    unawaited(_loadArtistImages(remoteOrFallback, requestId: requestId));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final suggestedArtists = _suggestedArtists();
    final influences = widget.cubit.state.influences;

    return Form(
      key: widget.formKey,
      child: MusicianOnboardingStepCard(
        title: loc.onboardingInfluencesTitle,
        description: loc.onboardingInfluencesDescription,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MusicianInfluencesInputRow(
              selectedStyle: _selectedStyle,
              artistController: _artistController,
              onStyleChanged: _onStyleChanged,
              onArtistChanged: (_) => setState(() {}),
              onAddInfluence: _addInfluence,
            ),
            MusicianInfluencesSuggestions(
              selectedStyle: _selectedStyle,
              loadingStyleOptions: _loadingStyleOptions,
              suggestedArtists: suggestedArtists,
              artistImagesByName: _artistImagesByName,
              influences: influences,
              onAddInfluence: (artist) => _addInfluence(artistName: artist),
              onRemoveInfluence: (artist) {
                final selectedStyle = _selectedStyle;
                if (selectedStyle == null) return;
                widget.cubit.removeInfluence(selectedStyle, artist);
                setState(_artistController.clear);
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<MusicianOnboardingCubit, MusicianOnboardingState>(
              bloc: widget.cubit,
              buildWhen: (prev, curr) => prev.influences != curr.influences,
              builder: (context, state) => MusicianInfluencesSelectedList(
                influences: state.influences,
                artistImagesByName: _artistImagesByName,
                onRemoveInfluence: widget.cubit.removeInfluence,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
