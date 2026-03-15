import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/repositories/auth_repository.dart';
import '../../notifications/models/venue_activity_notification_entity.dart';

/// Streams jam-session activity notifications for the authenticated venue owner.
///
/// Flow:
/// 1. Watches `venues` where `ownerId == uid` to obtain the venue IDs.
/// 2. If venue IDs exist, watches `jam_sessions` where `venueId in venueIds`
///    ordered by date descending, recycling the shared-stream broadcast pattern.
class VenueNotificationsRepository {
  VenueNotificationsRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
  }) : _firestore = firestore,
       _authRepository = authRepository;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  Stream<List<VenueActivityNotificationEntity>>? _sharedStream;
  StreamController<List<VenueActivityNotificationEntity>>? _controller;
  StreamSubscription? _sourceSubscription;

  /// Returns a shared broadcast stream of jam-session activity notifications
  /// associated with any venue owned by the current user.
  Stream<List<VenueActivityNotificationEntity>> watchVenueActivity() {
    if (_controller != null && !_controller!.isClosed) {
      return _sharedStream!;
    }

    _controller =
        StreamController<List<VenueActivityNotificationEntity>>.broadcast(
          onCancel: _tearDown,
        );
    _sharedStream = _controller!.stream;

    _sourceSubscription = _authRepository.idTokenChanges
        .asyncExpand((user) {
          if (user == null) {
            return Stream.value(const <VenueActivityNotificationEntity>[]);
          }
          final uid = user.id;

          // Watch venues for this owner, then flat-map to jam sessions.
          return _firestore
              .collection('venues')
              .where('ownerId', isEqualTo: uid)
              .snapshots()
              .asyncExpand((venueSnap) {
                final ids = venueSnap.docs.map((d) => d.id).toList();
                if (ids.isEmpty) {
                  return Stream.value(
                    const <VenueActivityNotificationEntity>[],
                  );
                }
                // Firestore whereIn supports up to 30 values.
                final chunk = ids.take(30).toList();
                return _firestore
                    .collection('jam_sessions')
                    .where('venueId', whereIn: chunk)
                    .orderBy('date', descending: true)
                    .limit(50)
                    .snapshots()
                    .map((snap) {
                      return snap.docs
                          .map(VenueActivityNotificationEntity.fromDoc)
                          .where((activity) => activity.venueId.isNotEmpty)
                          .toList();
                    });
              });
        })
        .listen(
          (data) {
            if (!_controller!.isClosed) _controller!.add(data);
          },
          onError: (Object e, StackTrace s) {
            if (!_controller!.isClosed) _controller!.addError(e, s);
            if (kDebugMode) debugPrint('[VenueNotifications] error: $e');
          },
        );

    return _sharedStream!;
  }

  void _tearDown() {
    _sourceSubscription?.cancel();
    _sourceSubscription = null;
    _controller?.close();
    _controller = null;
    _sharedStream = null;
  }
}
