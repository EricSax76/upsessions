import 'dart:async';

import '../domain/media_item.dart';

class MediaRepository {
  Future<List<MediaItem>> fetchMedia() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      MediaItem(id: 'm1', title: 'Track demo', type: MediaType.audio, duration: Duration(minutes: 3, seconds: 10), url: ''),
      MediaItem(id: 'm2', title: 'Live session', type: MediaType.video, duration: Duration(minutes: 5), url: ''),
      MediaItem(id: 'm3', title: 'Press photo', type: MediaType.image, duration: Duration.zero, url: ''),
    ];
  }
}
