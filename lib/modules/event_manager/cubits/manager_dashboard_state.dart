import 'package:equatable/equatable.dart';
import '../../../../modules/events/models/event_entity.dart';

class ManagerDashboardState extends Equatable {
  static const Object _unset = Object();

  const ManagerDashboardState({
    this.isLoading = true,
    this.upcomingEvents = const [],
    this.activeJamSessionsCount = 0,
    this.pendingRequestsCount = 0,
    this.totalEvents = 0,
    this.totalCapacity = 0,
    this.eventsThisWeek = 0,
    this.errorMessage,
  });

  final bool isLoading;
  final List<EventEntity> upcomingEvents;
  final int activeJamSessionsCount;
  final int pendingRequestsCount;

  // Stats
  final int totalEvents;
  final int totalCapacity;
  final int eventsThisWeek;

  final String? errorMessage;

  ManagerDashboardState copyWith({
    bool? isLoading,
    List<EventEntity>? upcomingEvents,
    int? activeJamSessionsCount,
    int? pendingRequestsCount,
    int? totalEvents,
    int? totalCapacity,
    int? eventsThisWeek,
    Object? errorMessage = _unset,
  }) {
    return ManagerDashboardState(
      isLoading: isLoading ?? this.isLoading,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      activeJamSessionsCount:
          activeJamSessionsCount ?? this.activeJamSessionsCount,
      pendingRequestsCount: pendingRequestsCount ?? this.pendingRequestsCount,
      totalEvents: totalEvents ?? this.totalEvents,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      eventsThisWeek: eventsThisWeek ?? this.eventsThisWeek,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    upcomingEvents,
    activeJamSessionsCount,
    pendingRequestsCount,
    totalEvents,
    totalCapacity,
    eventsThisWeek,
    errorMessage,
  ];
}
