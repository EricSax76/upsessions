import 'package:flutter/material.dart';

import '../../domain/media_item.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key, required this.item});

  final MediaItem item;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.item.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            IconButton(
              iconSize: 40,
              icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
              onPressed: () => setState(() => _isPlaying = !_isPlaying),
            ),
            Text('Duración ${widget.item.duration.inMinutes}:${(widget.item.duration.inSeconds % 60).toString().padLeft(2, '0')}'),
          ],
        ),
      ),
    );
  }
}
