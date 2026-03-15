import 'package:equatable/equatable.dart';

import '../models/room_entity.dart';
import '../models/studio_entity.dart';
import 'studios_status.dart';

class StudiosListState extends Equatable {
  static const Object _unset = Object();

  const StudiosListState({
    this.status = StudiosStatus.initial,
    this.studios = const [],
    this.hasMoreStudios = true,
    this.isLoadingStudiosMore = false,
    this.studiosCursor,
    this.selectedStudio,
    this.selectedStudioRooms = const [],
    this.errorMessage,
  });

  final StudiosStatus status;
  final List<StudioEntity> studios;
  final bool hasMoreStudios;
  final bool isLoadingStudiosMore;
  final String? studiosCursor;
  final StudioEntity? selectedStudio;
  final List<RoomEntity> selectedStudioRooms;
  final String? errorMessage;

  StudiosListState copyWith({
    StudiosStatus? status,
    List<StudioEntity>? studios,
    bool? hasMoreStudios,
    bool? isLoadingStudiosMore,
    Object? studiosCursor = _unset,
    Object? selectedStudio = _unset,
    List<RoomEntity>? selectedStudioRooms,
    Object? errorMessage = _unset,
  }) {
    return StudiosListState(
      status: status ?? this.status,
      studios: studios ?? this.studios,
      hasMoreStudios: hasMoreStudios ?? this.hasMoreStudios,
      isLoadingStudiosMore: isLoadingStudiosMore ?? this.isLoadingStudiosMore,
      studiosCursor: identical(studiosCursor, _unset)
          ? this.studiosCursor
          : studiosCursor as String?,
      selectedStudio: identical(selectedStudio, _unset)
          ? this.selectedStudio
          : selectedStudio as StudioEntity?,
      selectedStudioRooms: selectedStudioRooms ?? this.selectedStudioRooms,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    studios,
    hasMoreStudios,
    isLoadingStudiosMore,
    studiosCursor,
    selectedStudio,
    selectedStudioRooms,
    errorMessage,
  ];
}
