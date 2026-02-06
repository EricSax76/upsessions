import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../groups/models/group_dtos.dart';
import '../../groups/repositories/groups_repository.dart';
import '../models/rehearsal_entity.dart';
import '../models/setlist_item_entity.dart';
import '../../studios/models/booking_entity.dart';
import '../../studios/models/studio_entity.dart';
import '../../studios/repositories/studios_repository.dart';
import '../repositories/rehearsals_repository.dart';
import '../repositories/setlist_repository.dart';
import 'rehearsal_detail_state.dart';

class RehearsalDetailCubit extends Cubit<RehearsalDetailState> {
  RehearsalDetailCubit({
    required this.groupId,
    required this.rehearsalId,
    required this.userId,
    required this.groupsRepository,
    required this.rehearsalsRepository,
    required this.setlistRepository,
    required this.studiosRepository,
  }) : super(RehearsalDetailInitial()) {
    _subscribe();
  }

  final String groupId;
  final String rehearsalId;
  final String? userId;
  final GroupsRepository groupsRepository;
  final RehearsalsRepository rehearsalsRepository;
  final SetlistRepository setlistRepository;
  final StudiosRepository studiosRepository;

  final List<StreamSubscription> _subscriptions = [];
  GroupDoc? _group;
  RehearsalEntity? _rehearsal;
  List<SetlistItemEntity>? _setlist;
  BookingEntity? _booking;
  StudioEntity? _bookingStudio;
  String? _bookingIdInFlight;

  void _subscribe() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    emit(RehearsalDetailLoading());

    _subscriptions.add(
      groupsRepository.watchGroup(groupId).listen((group) {
        _group = group;
        _updateState();
      }, onError: _handleError),
    );

    _subscriptions.add(
      rehearsalsRepository
          .watchRehearsal(groupId: groupId, rehearsalId: rehearsalId)
          .listen((rehearsal) {
            _rehearsal = rehearsal;
            _loadBookingDetailsIfNeeded();
            _updateState();
          }, onError: _handleError),
    );

    _subscriptions.add(
      setlistRepository
          .watchSetlist(groupId: groupId, rehearsalId: rehearsalId)
          .listen((setlist) {
            _setlist = setlist;
            _updateState();
          }, onError: _handleError),
    );
  }

  void _updateState() {
    final group = _group;
    final rehearsal = _rehearsal;
    final setlist = _setlist;

    if (group == null || rehearsal == null || setlist == null) {
      // Still loading or not found
      if (rehearsal == null && group != null && setlist != null) {
        emit(const RehearsalDetailNotFound('Ensayo no encontrado.'));
      }
      return;
    }

    final canDelete = userId != null && group.ownerId == userId;

    emit(
      RehearsalDetailLoaded(
        group: group,
        rehearsal: rehearsal,
        setlist: setlist,
        canDelete: canDelete,
        booking: _booking,
        bookingStudio: _bookingStudio,
      ),
    );
  }

  Future<void> _loadBookingDetailsIfNeeded() async {
    final bookingId = _rehearsal?.bookingId?.trim();
    if (bookingId == null || bookingId.isEmpty) {
      if (_booking != null || _bookingStudio != null || _bookingIdInFlight != null) {
        _booking = null;
        _bookingStudio = null;
        _bookingIdInFlight = null;
        _updateState();
      }
      return;
    }

    if (_booking?.id == bookingId && _bookingStudio != null) {
      return;
    }
    if (_bookingIdInFlight == bookingId) {
      return;
    }

    _bookingIdInFlight = bookingId;
    try {
      final booking = await studiosRepository.getBookingById(bookingId);
      StudioEntity? studio;
      if (booking != null && booking.studioId.trim().isNotEmpty) {
        studio = await studiosRepository.getStudioById(booking.studioId);
      }
      if (_rehearsal?.bookingId?.trim() != bookingId) {
        return;
      }
      _booking = booking;
      _bookingStudio = studio;
    } finally {
      _bookingIdInFlight = null;
      _updateState();
    }
  }

  void _handleError(Object error) {
    emit(RehearsalDetailError(error.toString()));
  }

  Future<void> reorderSetlist(List<String> itemIdsInOrder) async {
    try {
      await setlistRepository.setSetlistOrders(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemIdsInOrder: itemIdsInOrder,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> close() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }
}
