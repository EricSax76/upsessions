import 'package:equatable/equatable.dart';
import '../../groups/models/group_dtos.dart';
import '../../studios/models/booking_entity.dart';
import '../../studios/models/studio_entity.dart';
import '../models/rehearsal_entity.dart';
import '../models/setlist_item_entity.dart';

abstract class RehearsalDetailState extends Equatable {
  const RehearsalDetailState();

  @override
  List<Object?> get props => [];
}

class RehearsalDetailInitial extends RehearsalDetailState {}

class RehearsalDetailLoading extends RehearsalDetailState {}

class RehearsalDetailLoaded extends RehearsalDetailState {
  const RehearsalDetailLoaded({
    required this.group,
    required this.rehearsal,
    required this.setlist,
    required this.canDelete,
    this.booking,
    this.bookingStudio,
  });

  final GroupDoc group;
  final RehearsalEntity rehearsal;
  final List<SetlistItemEntity> setlist;
  final bool canDelete;
  final BookingEntity? booking;
  final StudioEntity? bookingStudio;

  @override
  List<Object?> get props =>
      [group, rehearsal, setlist, canDelete, booking, bookingStudio];
}

class RehearsalDetailError extends RehearsalDetailState {
  const RehearsalDetailError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class RehearsalDetailNotFound extends RehearsalDetailState {
  const RehearsalDetailNotFound(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
