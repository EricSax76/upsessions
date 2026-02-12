import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/matching/repositories/matching_repository.dart';

void main() {
  group('MatchingRepository.calculateMatch', () {
    test('returns 0 score when no influences match', () {
      final myInfluences = {
        'Rock': ['The Beatles'],
      };
      final otherInfluences = {
        'Jazz': ['Miles Davis'],
      };

      final result = MatchingRepository.calculateMatch(myInfluences, otherInfluences);

      expect(result.score, 0);
      expect(result.shared, isEmpty);
    });

    test('returns correct score for shared styles only', () {
      final myInfluences = {
        'Rock': ['The Beatles'],
      };
      final otherInfluences = {
        'Rock': ['Led Zeppelin'],
      };

      final result = MatchingRepository.calculateMatch(myInfluences, otherInfluences);

      // +10 for shared style
      expect(result.score, 10);
      expect(result.shared, isEmpty); // No shared artists
    });

    test('returns correct score for shared artists', () {
      final myInfluences = {
        'Rock': ['The Beatles', 'Queen'],
      };
      final otherInfluences = {
        'Rock': ['The Beatles', 'Pink Floyd'],
      };

      final result = MatchingRepository.calculateMatch(myInfluences, otherInfluences);

      // +10 for shared style "Rock"
      // +20 for shared artist "The Beatles"
      // Total: 30
      expect(result.score, 30);
      expect(result.shared, containsPair('Rock', ['The Beatles']));
    });

    test('matches artists case-insensitively', () {
      final myInfluences = {
        'Rock': ['the beatles'],
      };
      final otherInfluences = {
        'Rock': ['The Beatles'],
      };

      final result = MatchingRepository.calculateMatch(myInfluences, otherInfluences);

      // +10 for shared style
      // +20 for shared artist
      // Total: 30
      expect(result.score, 30);
      expect(result.shared['Rock'], contains('The Beatles'));
    });

    test('accumulates score across multiple styles', () {
      final myInfluences = {
        'Rock': ['The Beatles'],
        'Jazz': ['Miles Davis'],
      };
      final otherInfluences = {
        'Rock': ['The Beatles'],
        'Jazz': ['John Coltrane'],
      };

      final result = MatchingRepository.calculateMatch(myInfluences, otherInfluences);

      // Rock: +10 (style) + 20 (Beatles) = 30
      // Jazz: +10 (style) + 0 (artists) = 10
      // Total: 40
      expect(result.score, 40);
      expect(result.shared.length, 1); // Only Rock has shared artists
      expect(result.shared, containsPair('Rock', ['The Beatles']));
    });
  });
}
