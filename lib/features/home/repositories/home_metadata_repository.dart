import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:upsessions/core/constants/spanish_geography.dart';
import 'package:upsessions/features/home/models/instrument_category_model.dart';

import 'home_repository_mappers.dart';

class HomeMetadataRepository {
  HomeMetadataRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<InstrumentCategoryModel>> fetchInstrumentCategories() async {
    final snapshot = await _firestore
        .collection('instrument_categories')
        .orderBy('category')
        .get();
    return snapshot.docs
        .map(
          (doc) => InstrumentCategoryModel(
            category: (doc.data()['category'] ?? '') as String,
            instruments: HomeRepositoryMappers.stringList(
              doc.data()['instruments'],
            ),
          ),
        )
        .toList();
  }

  Future<List<String>> fetchProvinces() async {
    final doc = await _firestore.collection('metadata').doc('geography').get();
    if (!doc.exists) {
      return spanishProvinces;
    }
    final provinces = HomeRepositoryMappers.stringList(
      doc.data()?['provinces'],
    );
    return provinces.isNotEmpty ? provinces : spanishProvinces;
  }

  Future<List<String>> fetchCitiesForProvince(String province) async {
    final doc = await _firestore.collection('metadata').doc('geography').get();
    final fallback = spanishCitiesByProvince[province] ?? const [];
    if (!doc.exists) {
      return fallback;
    }
    final data = doc.data();
    final byProvince = data?['citiesByProvince'];
    if (byProvince is Map<String, dynamic>) {
      final cities = byProvince[province];
      final resolved = HomeRepositoryMappers.stringList(cities);
      return resolved.isNotEmpty ? resolved : fallback;
    }
    return fallback;
  }
}
