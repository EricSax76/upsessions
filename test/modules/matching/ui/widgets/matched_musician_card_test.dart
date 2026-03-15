import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/matching/repositories/matching_repository.dart';
import 'package:upsessions/modules/matching/ui/widgets/matched_musician_card.dart';
import 'package:upsessions/modules/musicians/models/musician_compliance_info.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/musicians/models/musician_professional_info.dart';

void main() {
  MatchingResult buildMatch({required String? photoUrl}) {
    final musician = MusicianEntity(
      id: 'musician-1',
      ownerId: 'owner-1',
      name: 'Ana Luna',
      instrument: 'Guitarra',
      city: 'Madrid',
      styles: const ['Rock'],
      experienceYears: 4,
      photoUrl: photoUrl,
      compliance: MusicianComplianceInfo(updatedAt: DateTime(2026, 1, 1)),
      professional: const MusicianProfessionalInfo(),
    );

    return MatchingResult(
      musician: musician,
      score: 40,
      sharedInfluences: const {
        'Rock': ['Queen'],
      },
    );
  }

  testWidgets('shows initials when photoUrl is empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatchedMusicianCard(match: buildMatch(photoUrl: '')),
        ),
      ),
    );

    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('shows initials when photoUrl is invalid', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatchedMusicianCard(match: buildMatch(photoUrl: 'not-a-url')),
        ),
      ),
    );

    expect(find.text('AL'), findsOneWidget);
  });
}
