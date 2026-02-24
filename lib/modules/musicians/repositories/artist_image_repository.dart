import 'package:cloud_functions/cloud_functions.dart';

import '../models/artist_image_info.dart';

class ArtistImageRepository {
  ArtistImageRepository({required FirebaseFunctions functions})
    : _functions = functions;

  final FirebaseFunctions _functions;
  final Map<String, ArtistImageInfo> _cacheByArtistKey =
      <String, ArtistImageInfo>{};

  Future<Map<String, ArtistImageInfo>> resolveArtists(
    Iterable<String> artistNames,
  ) async {
    final requestedByKey = <String, String>{};
    for (final rawName in artistNames) {
      final trimmedName = rawName.trim();
      if (trimmedName.isEmpty) {
        continue;
      }
      final key = normalizeArtistName(trimmedName);
      requestedByKey[key] ??= trimmedName;
    }

    if (requestedByKey.isEmpty) {
      return const {};
    }

    final resolvedByKey = <String, ArtistImageInfo>{};
    final pendingByKey = <String, String>{};

    for (final entry in requestedByKey.entries) {
      final cached = _cacheByArtistKey[entry.key];
      if (cached != null) {
        resolvedByKey[entry.key] = cached;
        continue;
      }
      pendingByKey[entry.key] = entry.value;
    }

    if (pendingByKey.isNotEmpty) {
      final fetchedByKey = await _fetchFromCloudFunction(pendingByKey.values);
      for (final entry in pendingByKey.entries) {
        final info = fetchedByKey[entry.key] ?? const ArtistImageInfo();
        _cacheByArtistKey[entry.key] = info;
        resolvedByKey[entry.key] = info;
      }
    }

    return resolvedByKey;
  }

  Future<Map<String, ArtistImageInfo>> _fetchFromCloudFunction(
    Iterable<String> artistNames,
  ) async {
    try {
      final callable = _functions.httpsCallable('resolveSpotifyArtistImages');
      final result = await callable.call(<String, dynamic>{
        'artistNames': artistNames.toList(growable: false),
      });

      final data = result.data;
      if (data is! Map) {
        return const {};
      }

      final artistsRaw = data['artists'];
      if (artistsRaw is! Map) {
        return const {};
      }

      final parsed = <String, ArtistImageInfo>{};
      artistsRaw.forEach((artistName, infoRaw) {
        final key = normalizeArtistName(artistName.toString());
        if (key.isEmpty) {
          return;
        }
        parsed[key] = ArtistImageInfo.fromMap(infoRaw);
      });
      return parsed;
    } catch (_) {
      return const {};
    }
  }
}
