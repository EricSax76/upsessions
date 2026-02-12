import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/affinity_artist_options.dart';

class AffinityOptionsRepository {
  AffinityOptionsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'affinity_options';
  static const _docId = 'catalog';

  Map<String, List<String>>? _cachedRemoteArtistsByStyle;
  Future<Map<String, List<String>>>? _remoteLoadFuture;

  Future<List<String>> fetchArtistOptionsForStyle(String? style) async {
    final normalizedStyle = style?.trim() ?? '';
    if (normalizedStyle.isEmpty) {
      return const [];
    }

    final remoteArtistsByStyle = await _loadRemoteArtistsByStyle();
    final remoteArtists = _lookupStyle(remoteArtistsByStyle, normalizedStyle);
    if (remoteArtists.isNotEmpty) {
      return remoteArtists;
    }

    return affinityArtistOptionsForStyle(normalizedStyle);
  }

  Future<Map<String, List<String>>> _loadRemoteArtistsByStyle() async {
    final cached = _cachedRemoteArtistsByStyle;
    if (cached != null) {
      return cached;
    }

    final pending = _remoteLoadFuture;
    if (pending != null) {
      return pending;
    }

    final future = _fetchRemoteArtistsByStyle();
    _remoteLoadFuture = future;

    try {
      final loaded = await future;
      _cachedRemoteArtistsByStyle = loaded;
      return loaded;
    } finally {
      _remoteLoadFuture = null;
    }
  }

  Future<Map<String, List<String>>> _fetchRemoteArtistsByStyle() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_docId).get();

      if (!doc.exists) {
        return const {};
      }

      final data = doc.data() ?? const <String, dynamic>{};
      final rawByStyle =
          data['artistsByStyle'] ??
          data['optionsByStyle'] ??
          data['styles'] ??
          data;

      final parsed = _parseArtistsByStyle(rawByStyle);
      return parsed;
    } catch (_) {
      return const {};
    }
  }

  static Map<String, List<String>> _parseArtistsByStyle(dynamic raw) {
    if (raw is! Map) {
      return const {};
    }

    final parsed = <String, List<String>>{};
    raw.forEach((key, value) {
      final style = key.toString().trim();
      if (style.isEmpty) {
        return;
      }

      final artists = _parseArtistList(value);
      if (artists.isNotEmpty) {
        parsed[style] = artists;
      }
    });

    return parsed;
  }

  static List<String> _parseArtistList(dynamic raw) {
    if (raw is String) {
      return _parsePipeSeparatedArtists(raw);
    }

    if (raw is! Iterable) {
      return const [];
    }

    final parsed = <String>[];
    final seen = <String>{};
    for (final item in raw) {
      final artist = item.toString().trim();
      if (artist.isEmpty) {
        continue;
      }
      final key = artist.toLowerCase();
      if (seen.add(key)) {
        parsed.add(artist);
      }
    }

    return parsed;
  }

  static List<String> _parsePipeSeparatedArtists(String raw) {
    final parsed = <String>[];
    final seen = <String>{};

    for (final token in raw.split('|')) {
      var artist = token.trim();
      if (artist.isEmpty) {
        continue;
      }

      artist = artist.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
      artist = artist.replaceFirst(RegExp(r'^[•·-]\s*'), '').trim();
      if (artist.endsWith('.')) {
        artist = artist.substring(0, artist.length - 1).trim();
      }

      if (artist.isEmpty) {
        continue;
      }

      final key = artist.toLowerCase();
      if (seen.add(key)) {
        parsed.add(artist);
      }
    }

    return parsed;
  }

  static List<String> _lookupStyle(
    Map<String, List<String>> artistsByStyle,
    String style,
  ) {
    final exact = artistsByStyle[style];
    if (exact != null && exact.isNotEmpty) {
      return exact;
    }

    final normalized = style.toLowerCase();
    for (final entry in artistsByStyle.entries) {
      if (entry.key.trim().toLowerCase() == normalized &&
          entry.value.isNotEmpty) {
        return entry.value;
      }
    }

    return const [];
  }
}
