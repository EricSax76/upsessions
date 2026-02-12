import 'package:cloud_firestore/cloud_firestore.dart';

import '../../musicians/models/musician_dto.dart';
import '../../musicians/models/musician_entity.dart';

class MatchingRepository {
  MatchingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<MatchingResult>> findMatches({
    required Map<String, List<String>> myInfluences,
    required String myId,
    int limit = 20,
  }) async {
    if (myInfluences.isEmpty) return [];

    final snapshot = await _firestore
        .collection('musicians')
        .orderBy('updatedAt', descending: true)
        .limit(100)
        .get();

    final candidates = snapshot.docs
        .map(MusicianDto.fromDocument)
        .where((dto) => dto.id != myId) // Exclude myself
        .map((dto) => dto.toEntity())
        .toList();

    // 2. Client-side scoring
    final scoredCandidates = candidates.map((musician) {
      final matchData = calculateMatch(myInfluences, musician.influences);
      return MatchingResult(
        musician: musician,
        score: matchData.score,
        sharedInfluences: matchData.shared,
      );
    }).where((result) => result.score > 0).toList();

    // 3. Sort by score
    scoredCandidates.sort((a, b) => b.score.compareTo(a.score));

    // 4. Return top matches
    return scoredCandidates.take(limit).toList();
  }

  static MatchData calculateMatch(
    Map<String, List<String>> myInfluences,
    Map<String, List<String>> otherInfluences,
  ) {
    if (otherInfluences.isEmpty) return MatchData(0, {});

    int score = 0;
    final shared = <String, List<String>>{};

    for (final style in myInfluences.keys) {
      if (otherInfluences.containsKey(style)) {
        // Shared style: +10 points
        score += 10;

        final myArtists = myInfluences[style]!
            .map((e) => e.trim().toLowerCase())
            .toSet();
        final otherArtistsOriginal = otherInfluences[style]!;
        
        // Find shared artists (case-insensitive check, preserve original casing from 'other')
        final sharedArtistsForStyle = <String>[];
        
        for (final artist in otherArtistsOriginal) {
          if (myArtists.contains(artist.trim().toLowerCase())) {
            sharedArtistsForStyle.add(artist);
          }
        }

        if (sharedArtistsForStyle.isNotEmpty) {
             score += sharedArtistsForStyle.length * 20;
             shared[style] = sharedArtistsForStyle;
        }
      }
    }

    return MatchData(score, shared);
  }
}

class MatchingResult {
  const MatchingResult({
    required this.musician,
    required this.score,
    required this.sharedInfluences,
  });

  final MusicianEntity musician;
  final int score;
  final Map<String, List<String>> sharedInfluences;
}

class MatchData {
  const MatchData(this.score, this.shared);
  final int score;
  final Map<String, List<String>> shared;
}
