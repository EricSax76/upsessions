import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../messaging/repositories/chat_repository.dart';
import '../repositories/invite_notifications_repository.dart';

class NotificationsStatusCubit extends Cubit<int> {
  NotificationsStatusCubit({
    required ChatRepository chatRepository,
    required InviteNotificationsRepository inviteNotificationsRepository,
  })  : _chatRepository = chatRepository,
        _inviteNotificationsRepository = inviteNotificationsRepository,
        super(0) {
    _start();
  }

  final ChatRepository _chatRepository;
  final InviteNotificationsRepository _inviteNotificationsRepository;
  
  StreamSubscription? _chatSubscription;
  StreamSubscription? _inviteSubscription;
  
  int _unreadChats = 0;
  int _unreadInvites = 0;

  void _start() {
    _chatSubscription = _chatRepository.watchUnreadTotal().listen((count) {
      _unreadChats = count;
      _emitTotal();
    });

    _inviteSubscription = _inviteNotificationsRepository.watchMyInvites().listen((invites) {
      _unreadInvites = invites.where((i) => !i.read).length;
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
