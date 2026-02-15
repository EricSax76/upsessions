import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:upsessions/core/locator/locator.dart';
import '../../cubits/media_gallery_cubit.dart';
import '../../cubits/media_gallery_state.dart';
import '../../repositories/media_repository.dart';
import '../widgets/media_grid.dart';

class MediaGalleryPage extends StatelessWidget {
  const MediaGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MediaGalleryCubit(
        repository: locate<MediaRepository>(),
      )..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Galería')),
        body: BlocBuilder<MediaGalleryCubit, MediaGalleryState>(
          builder: (context, state) {
            return MediaGrid(
              items: state.items,
              isLoading: state.isLoading,
            );
          },
        ),
      ),
    );
  }
}
