import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:upsessions/modules/musicians/repositories/musician_notifications_repository.dart';

class NotificationsStatusCubit extends Cubit<int> {
  NotificationsStatusCubit({
    required MusicianNotificationsRepository musicianNotificationsRepository,
  }) : _musicianNotificationsRepository = musicianNotificationsRepository,
       super(0) {
    _start();
  }

  final MusicianNotificationsRepository _musicianNotificationsRepository;

  StreamSubscription? _chatSubscription;
  StreamSubscription? _inviteSubscription;

  int _unreadChats = 0;
  int _unreadInvites = 0;

  void _start() {
    _chatSubscription = _musicianNotificationsRepository
        .watchUnreadChatsCount()
        .listen((count) {
          _unreadChats = count;
          _emitTotal();
        });

    _inviteSubscription = _musicianNotificationsRepository
        .watchUnreadInvitesCount()
        .listen((count) {
          _unreadInvites = count;
          _emitTotal();
        });
  }

  void _emitTotal() {
    emit(_unreadChats + _unreadInvites);
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    _inviteSubscription?.cancel();
    return super.close();
  }
}
