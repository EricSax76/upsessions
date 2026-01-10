part of 'rehearsals_groups_cubit.dart';

class RehearsalsGroupsState extends Equatable {
  const RehearsalsGroupsState({
    this.memberships = const [],
    this.totalMemberships = 0,
    this.isLoading = false,
    this.query = '',
    this.errorMessage,
  });

  static const Object _unset = Object();

  final List<GroupMembershipEntity> memberships;
  final int totalMemberships;
  final bool isLoading;
  final String query;
  final String? errorMessage;

  RehearsalsGroupsState copyWith({
    List<GroupMembershipEntity>? memberships,
    int? totalMemberships,
    bool? isLoading,
    String? query,
    Object? errorMessage = _unset,
  }) {
    return RehearsalsGroupsState(
      memberships: memberships ?? this.memberships,
      totalMemberships: totalMemberships ?? this.totalMemberships,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props =>
      [memberships, totalMemberships, isLoading, query, errorMessage];
}

