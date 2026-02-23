import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/liked_musician.dart';

class ContactsRepository {
  ContactsRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const _musiciansCollection = 'musicians';
  static const _contactsCollection = 'contacts';

  CollectionReference<Map<String, dynamic>> _contactsRef(String ownerId) {
    return _firestore
        .collection(_musiciansCollection)
        .doc(ownerId)
        .collection(_contactsCollection);
  }

  Stream<List<LikedMusician>> watchContacts(String ownerId) {
    return _contactsRef(ownerId).snapshots().map((snapshot) {
      return snapshot.docs.map(_mapDocument).toList();
    });
  }

  Future<void> saveContact({
    required String ownerId,
    required LikedMusician contact,
  }) async {
    await _contactsRef(ownerId).doc(contact.id).set({
      'id': contact.id,
      'ownerId': contact.ownerId,
      'name': contact.name,
      'instrument': contact.instrument,
      'city': contact.city,
      'styles': contact.styles,
      'highlightStyle': contact.highlightStyle,
      'photoUrl': contact.photoUrl,
      'experienceYears': contact.experienceYears,
      'rating': contact.rating,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteContact({
    required String ownerId,
    required String contactId,
  }) {
    return _contactsRef(ownerId).doc(contactId).delete();
  }

  LikedMusician _mapDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return LikedMusician(
      id: doc.id,
      ownerId: (data['ownerId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      instrument: (data['instrument'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      styles: (data['styles'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      highlightStyle: data['highlightStyle'] as String?,
      photoUrl: data['photoUrl'] as String?,
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble(),
    );
  }
}
