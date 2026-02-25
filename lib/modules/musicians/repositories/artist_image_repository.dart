import 'dart:math' as math;

import 'package:cloud_functions/cloud_functions.dart';

import '../models/artist_image_info.dart';

class ArtistImageRepository {
  ArtistImageRepository({required FirebaseFunctions functions})
    : _functions = functions;

  static const int _maxArtistsPerFunctionCall = 30;
  static const int _parallelBatchCalls = 2;

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
      final fetchedByKey = await _fetchInBatches(pendingByKey.values);
      for (final entry in pendingByKey.entries) {
        final info = fetchedByKey[entry.key];
        if (info == null) {
          continue;
        }
        if (_shouldCache(info)) {
          _cacheByArtistKey[entry.key] = info;
        }
        resolvedByKey[entry.key] = info;
      }
    }

    return resolvedByKey;
  }

  Future<Map<String, ArtistImageInfo>> _fetchInBatches(
    Iterable<String> artistNames,
  ) async {
    final names = artistNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    if (names.isEmpty) {
      return const {};
    }

    final batches = <List<String>>[];
    for (
      var index = 0;
      index < names.length;
      index += _maxArtistsPerFunctionCall
    ) {
      final end = math.min(index + _maxArtistsPerFunctionCall, names.length);
      batches.add(names.sublist(index, end));
    }

    final merged = <String, ArtistImageInfo>{};
    for (var index = 0; index < batches.length; index += _parallelBatchCalls) {
      final end = math.min(index + _parallelBatchCalls, batches.length);
      final window = batches.sublist(index, end);
      final results = await Future.wait(
        window.map((batch) => _fetchFromCloudFunction(batch)),
      );
      for (final fetched in results) {
        if (fetched.isEmpty) {
          continue;
        }
        merged.addAll(fetched);
      }
    }
    return merged;
  }

  bool _shouldCache(ArtistImageInfo info) {
    final spotifyUrl = info.spotifyUrl?.trim() ?? '';
    return info.hasImage || spotifyUrl.isNotEmpty;
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
