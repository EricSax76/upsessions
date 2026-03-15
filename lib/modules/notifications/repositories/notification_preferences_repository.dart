import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../auth/repositories/auth_repository.dart';
import '../models/notification_preferences_entity.dart';
import '../models/notification_scenario.dart';

typedef TimezoneProvider = Future<String> Function();

class NotificationPreferencesRepository {
  NotificationPreferencesRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
    TimezoneProvider? timezoneProvider,
  }) : _firestore = firestore,
       _authRepository = authRepository,
       _timezoneProvider = timezoneProvider ?? _defaultTimezoneProvider;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final TimezoneProvider _timezoneProvider;

  Stream<NotificationPreferencesEntity>? _sharedStream;
  StreamController<NotificationPreferencesEntity>? _controller;
  StreamSubscription? _sourceSubscription;

  Stream<NotificationPreferencesEntity> watchPreferences() {
    if (_controller != null && !_controller!.isClosed) {
      return _sharedStream!;
    }

    _controller = StreamController<NotificationPreferencesEntity>.broadcast(
      onCancel: _tearDown,
    );
    _sharedStream = _controller!.stream;

    _sourceSubscription = _authRepository.idTokenChanges
        .asyncExpand((user) {
          if (user == null) {
            return Stream.value(NotificationPreferencesEntity.defaults);
          }
          return _docRef(user.id).snapshots().map((snapshot) {
            return NotificationPreferencesEntity.fromFirestore(snapshot.data());
          });
        })
        .listen(
          (entity) {
            if (!_controller!.isClosed) _controller!.add(entity);
          },
          onError: (Object e, StackTrace s) {
            if (!_controller!.isClosed) _controller!.addError(e, s);
          },
        );

    return _sharedStream!;
  }

  Future<void> setScenarioChannel(
    NotificationScenario scenario,
    NotificationChannel channel,
    bool enabled,
  ) async {
    if (!scenario.metadata.channels.contains(channel)) {
      throw ArgumentError.value(
        channel,
        'channel',
        'Channel is not enabled in scenario metadata',
      );
    }

    final uid = _requireUid();
    final channelField = NotificationPreferencesEntity.channelFieldName(
      channel,
    );
    await _docRef(uid).set({
      'scenarios.${scenario.wireKey}.$channelField': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setQuietHours({
    required bool enabled,
    required int start,
    required int end,
  }) async {
    _validateHour('start', start);
    _validateHour('end', end);

    final uid = _requireUid();
    final timezone = await _resolveTimezone();
    await _docRef(uid).set({
      'quietHours.enabled': enabled,
      'quietHours.startHour': start,
      'quietHours.endHour': end,
      'quietHours.timezone': timezone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _docRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notificationPreferences')
        .doc('prefs');
  }

  String _requireUid() {
    final uid = _authRepository.currentUser?.id.trim();
    if (uid == null || uid.isEmpty) {
      throw StateError('No authenticated user');
    }
    return uid;
  }

  Future<String> _resolveTimezone() async {
    try {
      final timezone = (await _timezoneProvider()).trim();
      if (timezone.isNotEmpty) return timezone;
    } catch (_) {
      // Best-effort only; fallback to UTC.
    }
    return 'UTC';
  }

  static Future<String> _defaultTimezoneProvider() {
    return FlutterTimezone.getLocalTimezone();
  }

  static void _validateHour(String field, int value) {
    if (value < 0 || value > 23) {
      throw RangeError.range(value, 0, 23, field);
    }
  }

  void _tearDown() {
    _sourceSubscription?.cancel();
    _sourceSubscription = null;
    _controller?.close();
    _controller = null;
    _sharedStream = null;
  }
}
