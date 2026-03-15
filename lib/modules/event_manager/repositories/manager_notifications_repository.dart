import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/repositories/auth_repository.dart';
import '../../notifications/models/manager_request_notification_entity.dart';

/// Streams musician-request notifications for the authenticated event manager.
///
/// Watches `musician_requests` where `managerId == uid`, ordered by
/// creation date. Supports marking individual requests as read via
/// the `readByManager` Firestore field.
class ManagerNotificationsRepository {
  ManagerNotificationsRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
  }) : _collection = firestore.collection('musician_requests'),
       _authRepository = authRepository;

  final CollectionReference<Map<String, dynamic>> _collection;
  final AuthRepository _authRepository;

  Stream<List<ManagerRequestNotificationEntity>>? _sharedStream;
  StreamController<List<ManagerRequestNotificationEntity>>? _controller;
  StreamSubscription? _sourceSubscription;

  /// Returns a shared broadcast stream of the manager's musician requests,
  /// most recent first. Tears down the Firestore listener when the last
  /// consumer cancels.
  Stream<List<ManagerRequestNotificationEntity>> watchRequests() {
    if (_controller != null && !_controller!.isClosed) {
      return _sharedStream!;
    }

    _controller =
        StreamController<List<ManagerRequestNotificationEntity>>.broadcast(
          onCancel: _tearDown,
        );
    _sharedStream = _controller!.stream;

    _sourceSubscription = _authRepository.idTokenChanges
        .asyncExpand((user) {
          if (user == null) {
            return Stream.value(const <ManagerRequestNotificationEntity>[]);
          }
          final uid = user.id;
          return _collection
              .where('managerId', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .limit(100)
              .snapshots()
              .map((snap) {
                return snap.docs
                    .map(ManagerRequestNotificationEntity.fromDoc)
                    .toList();
              });
        })
        .listen(
          (data) {
            if (!_controller!.isClosed) _controller!.add(data);
          },
          onError: (Object e, StackTrace s) {
            if (!_controller!.isClosed) _controller!.addError(e, s);
            if (kDebugMode) debugPrint('[ManagerNotifications] error: $e');
          },
        );

    return _sharedStream!;
  }

  /// Marks a musician request as read by the manager.
  Future<void> markRead(String requestId) async {
    await _collection.doc(requestId).set({
      'readByManager': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _tearDown() {
    _sourceSubscription?.cancel();
    _sourceSubscription = null;
    _controller?.close();
    _controller = null;
    _sharedStream = null;
  }
}
