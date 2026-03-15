class ArtistImageInfo {
  const ArtistImageInfo({this.imageUrl, this.spotifyUrl});

  final String? imageUrl;
  final String? spotifyUrl;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  factory ArtistImageInfo.fromMap(dynamic raw) {
    if (raw is! Map) {
      return const ArtistImageInfo();
    }
    final imageUrl = _asNullableString(raw['imageUrl']);
    final spotifyUrl = _asNullableString(raw['spotifyUrl']);
    return ArtistImageInfo(imageUrl: imageUrl, spotifyUrl: spotifyUrl);
  }

  static String? _asNullableString(dynamic value) {
    final parsed = value?.toString().trim();
    if (parsed == null || parsed.isEmpty) {
      return null;
    }
    return parsed;
  }
}
