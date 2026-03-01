import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gig_offer_dto.dart';
import '../models/gig_offer_entity.dart';
import '../../auth/repositories/auth_repository.dart';

class GigOffersRepository {
  GigOffersRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
  })  : _collection = firestore.collection('gig_offers'),
        _authRepository = authRepository;

  final CollectionReference<Map<String, dynamic>> _collection;
  final AuthRepository _authRepository;

  Future<List<GigOfferEntity>> fetchManagerOffers() async {
    final managerId = _authRepository.currentUser?.id ?? '';
    if (managerId.isEmpty) throw Exception('No autenticado');

    final snapshot = await _collection
        .where('managerId', isEqualTo: managerId)
        .orderBy('createdAt', descending: true)
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<List<GigOfferEntity>> fetchOpenOffers() async {
    final snapshot = await _collection
        .where('status', isEqualTo: GigOfferStatus.open.name)
        .orderBy('createdAt', descending: true)
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<GigOfferEntity> saveOffer(GigOfferEntity offer) async {
    final managerId = _authRepository.currentUser?.id ?? '';
    if (managerId.isEmpty) throw Exception('No autenticado');

    final dto = GigOfferDto.fromEntity(offer.copyWith(managerId: managerId));
    final now = FieldValue.serverTimestamp();
    final payload = {
      ...dto.toJson(),
      if (offer.id.isEmpty) 'createdAt': now,
    };

    if (offer.id.isEmpty) {
      final ref = await _collection.add(payload);
      final snapshot = await ref.get();
      return GigOfferDto.fromDocument(snapshot).toEntity();
    }

    await _collection.doc(offer.id).set(payload, SetOptions(merge: true));
    final snapshot = await _collection.doc(offer.id).get();
    return GigOfferDto.fromDocument(snapshot).toEntity();
  }

  Future<void> deleteOffer(String offerId) async {
    await _collection.doc(offerId).delete();
  }

  List<GigOfferEntity> _toEntities(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map((doc) => GigOfferDto.fromDocument(doc))
        .map((dto) => dto.toEntity())
        .toList();
  }
}
