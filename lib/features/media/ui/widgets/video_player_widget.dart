import 'package:flutter/material.dart';

import '../../models/media_item.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_outline, size: 48),
          const SizedBox(height: 12),
          Text(item.title, style: Theme.of(context).textTheme.titleMedium),
          Text(
            'Duración ${item.duration.inMinutes}:${(item.duration.inSeconds % 60).toString().padLeft(2, '0')}',
          ),
        ],
      ),
    );
  }
}
