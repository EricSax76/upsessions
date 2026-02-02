import 'package:flutter/material.dart';

import '../../models/media_item.dart';
import 'audio_player_widget.dart';
import 'video_player_widget.dart';

class MediaGrid extends StatelessWidget {
  const MediaGrid({
    super.key,
    required this.items,
    this.isLoading = false,
  });

  final List<MediaItem> items;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No hay elementos multimedia',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        switch (item.type) {
          case MediaType.audio:
            return AudioPlayerWidget(item: item);
          case MediaType.video:
            return VideoPlayerWidget(item: item);
          case MediaType.image:
            return Card(child: Center(child: Text(item.title)));
        }
      },
    );
  }
}
