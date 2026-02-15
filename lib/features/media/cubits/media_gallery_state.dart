import 'package:equatable/equatable.dart';

import '../models/media_item.dart';

enum MediaGalleryStatus { initial, loading, loaded, error }

class MediaGalleryState extends Equatable {
  const MediaGalleryState({
    this.status = MediaGalleryStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final MediaGalleryStatus status;
  final List<MediaItem> items;
  final String? errorMessage;

  bool get isLoading => status == MediaGalleryStatus.loading;

  MediaGalleryState copyWith({
    MediaGalleryStatus? status,
    List<MediaItem>? items,
    String? errorMessage,
  }) {
    return MediaGalleryState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
