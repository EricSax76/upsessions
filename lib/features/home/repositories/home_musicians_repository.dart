import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:upsessions/modules/musicians/models/musician_entity.dart';

import 'home_repository_mappers.dart';

class HomeMusiciansRepository {
  HomeMusiciansRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<MusicianEntity>> fetchRecommendedMusicians() async {
    final snapshot = await _firestore
        .collection('musicians')
        .orderBy('rating', descending: true)
        .limit(6)
        .get();
    return snapshot.docs.map(HomeRepositoryMappers.musicianFromDoc).toList();
  }

  Future<List<MusicianEntity>> fetchNewMusicians() async {
    final snapshot = await _firestore
        .collection('musicians')
        .orderBy('createdAt', descending: true)
        .limit(6)
        .get();
    return snapshot.docs.map(HomeRepositoryMappers.musicianFromDoc).toList();
  }
}
