import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../auth/models/user_entity.dart';
import '../../event_manager/repositories/manager_notifications_repository.dart';
import '../../musicians/repositories/musician_notifications_repository.dart';
import '../../studios/repositories/studio_notifications_repository.dart';
import '../../venues/repositories/venue_notifications_repository.dart';

class NotificationCenterCubit extends Cubit<int> {
  NotificationCenterCubit({
    required UserRole role,
    required MusicianNotificationsRepository musicianNotificationsRepository,
    required StudioNotificationsRepository studioNotificationsRepository,
    required ManagerNotificationsRepository managerNotificationsRepository,
    required VenueNotificationsRepository venueNotificationsRepository,
    this.isVenueSession = false,
  }) : _musicianNotificationsRepository = musicianNotificationsRepository,
       _studioNotificationsRepository = studioNotificationsRepository,
       _managerNotificationsRepository = managerNotificationsRepository,
       _venueNotificationsRepository = venueNotificationsRepository,
       super(0) {
    _start(role);
  }

  final MusicianNotificationsRepository _musicianNotificationsRepository;
  final StudioNotificationsRepository _studioNotificationsRepository;
  final ManagerNotificationsRepository _managerNotificationsRepository;
  final VenueNotificationsRepository _venueNotificationsRepository;

  final bool isVenueSession;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  int _unreadChats = 0;
  int _unreadInvites = 0;

  void _start(UserRole role) {
    switch (role) {
      case UserRole.musician:
        _startMusician();
      case UserRole.studio:
        _startStudio();
      case UserRole.manager:
        if (isVenueSession) {
          _startVenue();
        } else {
          _startManager();
        }
      case UserRole.admin:
        emit(0);
    }
  }

  void _startMusician() {
    _subscriptions.add(
      _musicianNotificationsRepository.watchUnreadChatsCount().listen((count) {
        _unreadChats = count;
        _emitTotal();
      }),
    );

    _subscriptions.add(
      _musicianNotificationsRepository.watchUnreadInvitesCount().listen((
        count,
      ) {
        _unreadInvites = count;
        _emitTotal();
      }),
    );
  }

  void _startStudio() {
    _subscriptions.add(
      _studioNotificationsRepository.watchPendingBookings().listen((bookings) {
        emit(bookings.where((booking) => !booking.read).length);
      }),
    );
  }

  void _startManager() {
    _subscriptions.add(
      _managerNotificationsRepository.watchRequests().listen((requests) {
        emit(requests.where((request) => !request.read).length);
      }),
    );
  }

  void _startVenue() {
    _subscriptions.add(
      _venueNotificationsRepository.watchVenueActivity().listen((activity) {
        emit(activity.length);
      }),
    );
  }

  void _emitTotal() {
    emit(_unreadChats + _unreadInvites);
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
