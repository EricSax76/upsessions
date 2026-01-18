part of 'groups_cubit.dart';

class GroupsState extends Equatable {
  const GroupsState({
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

  GroupsState copyWith({
    List<GroupMembershipEntity>? memberships,
    int? totalMemberships,
    bool? isLoading,
    String? query,
    Object? errorMessage = _unset,
  }) {
    return GroupsState(
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
