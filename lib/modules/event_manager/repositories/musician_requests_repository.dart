import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/musician_request_dto.dart';
import '../models/musician_request_entity.dart';
import '../../auth/repositories/auth_repository.dart';

class MusicianRequestsRepository {
  MusicianRequestsRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
  })  : _collection = firestore.collection('musician_requests'),
        _authRepository = authRepository;

  final CollectionReference<Map<String, dynamic>> _collection;
  final AuthRepository _authRepository;

  Future<List<MusicianRequestEntity>> fetchManagerRequests() async {
    final managerId = _authRepository.currentUser?.id ?? '';
    if (managerId.isEmpty) throw Exception('No autenticado');

    final snapshot = await _collection
        .where('managerId', isEqualTo: managerId)
        .orderBy('createdAt', descending: true)
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<MusicianRequestEntity> sendRequest(MusicianRequestEntity request) async {
    final managerId = _authRepository.currentUser?.id ?? '';
    if (managerId.isEmpty) throw Exception('No autenticado');

    final payload = {
      ...MusicianRequestDto.fromEntity(request.copyWith(managerId: managerId)).toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    final ref = await _collection.add(payload);
    final snapshot = await ref.get();
    return MusicianRequestDto.fromDocument(snapshot).toEntity();
  }

  Future<void> updateStatus(String requestId, RequestStatus newStatus) async {
    await _collection.doc(requestId).update({'status': newStatus.name});
  }

  Future<void> deleteRequest(String requestId) async {
    await _collection.doc(requestId).delete();
  }

  List<MusicianRequestEntity> _toEntities(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map((doc) => MusicianRequestDto.fromDocument(doc))
        .map((dto) => dto.toEntity())
        .toList();
  }
}
