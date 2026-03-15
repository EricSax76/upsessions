import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../modules/notifications/models/studio_booking_notification_entity.dart';
import '../../../modules/rehearsals/repositories/rehearsals_repository_base.dart';

/// Streams pending booking notifications for the studio owner.
///
/// Watches the top-level `bookings` collection filtered by the owner's
/// studio and `status == 'pending'`, recycling the shared-stream pattern
/// from [InviteNotificationsRepository].
class StudioNotificationsRepository extends RehearsalsRepositoryBase {
  StudioNotificationsRepository({
    required super.firestore,
    required super.authRepository,
  });

  Stream<List<StudioBookingNotificationEntity>>? _sharedStream;
  StreamController<List<StudioBookingNotificationEntity>>? _controller;
  StreamSubscription? _sourceSubscription;

  /// Returns a shared broadcast stream of pending booking notifications
  /// for the authenticated studio owner.
  Stream<List<StudioBookingNotificationEntity>> watchPendingBookings() {
    if (_controller != null && !_controller!.isClosed) {
      return _sharedStream!;
    }

    _controller =
        StreamController<List<StudioBookingNotificationEntity>>.broadcast(
          onCancel: _tearDown,
        );
    _sharedStream = _controller!.stream;

    _sourceSubscription = authRepository.idTokenChanges
        .asyncExpand((user) {
          if (user == null) {
            return Stream.value(const <StudioBookingNotificationEntity>[]);
          }
          final uid = user.id;

          // First fetch the studio owned by this user, then watch its bookings.
          final studioStream = firestore
              .collection('studios')
              .where('ownerId', isEqualTo: uid)
              .limit(1)
              .snapshots()
              .asyncExpand((studioSnap) {
                if (studioSnap.docs.isEmpty) {
                  return Stream.value(
                    const <StudioBookingNotificationEntity>[],
                  );
                }
                final studioId = studioSnap.docs.first.id;
                return firestore
                    .collection('bookings')
                    .where('studioId', isEqualTo: studioId)
                    .where('status', isEqualTo: 'pending')
                    .orderBy('createdAt', descending: true)
                    .limit(100)
                    .snapshots()
                    .map((snap) {
                      return snap.docs
                          .where((doc) => doc.data().isNotEmpty)
                          .map(StudioBookingNotificationEntity.fromDoc)
                          .where(
                            (notification) => notification.studioId.isNotEmpty,
                          )
                          .toList();
                    });
              });

          return logStream('watchPendingBookings', studioStream);
        })
        .listen(
          (data) {
            if (!_controller!.isClosed) _controller!.add(data);
          },
          onError: (Object e, StackTrace s) {
            if (!_controller!.isClosed) _controller!.addError(e, s);
          },
        );

    return _sharedStream!;
  }

  /// Marks a booking as read by the studio owner (stores `readByOwner: true`).
  Future<void> markRead(String bookingId) async {
    await logFuture(
      'markBookingNotificationRead',
      firestore.collection('bookings').doc(bookingId).set({
        'readByOwner': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
  }

  void _tearDown() {
    _sourceSubscription?.cancel();
    _sourceSubscription = null;
    _controller?.close();
    _controller = null;
    _sharedStream = null;
  }
}
