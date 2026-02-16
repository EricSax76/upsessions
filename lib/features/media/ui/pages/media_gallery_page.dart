import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/media_gallery_cubit.dart';
import '../../cubits/media_gallery_state.dart';
import '../../repositories/media_repository.dart';
import '../widgets/media_grid.dart';

class MediaGalleryPage extends StatelessWidget {
  const MediaGalleryPage({super.key, required this.repository});

  final MediaRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MediaGalleryCubit(
        repository: repository,
      )..load(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Galería',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<MediaGalleryCubit, MediaGalleryState>(
                  builder: (context, state) {
                    return MediaGrid(
                      items: state.items,
                      isLoading: state.isLoading,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
