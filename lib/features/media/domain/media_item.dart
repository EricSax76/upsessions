enum MediaType { audio, video, image }

class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.url,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final MediaType type;
  final Duration duration;
  final String url;
  final String? thumbnailUrl;
}
