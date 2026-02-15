part of 'announcements_list_cubit.dart';

enum AnnouncementsListStatus { initial, loading, success, failure }

final class AnnouncementsListState extends Equatable {
  const AnnouncementsListState({
    this.status = AnnouncementsListStatus.initial,
    this.items = const [],
    this.filter = AnnouncementUiFilter.all,
    this.hasMore = true,
    this.nextCursor,
    this.errorMessage,
    this.isLoadingMore = false,
  });

  final AnnouncementsListStatus status;
  final List<AnnouncementEntity> items;
  final AnnouncementUiFilter filter;
  final bool hasMore;
  final String? nextCursor;
  final String? errorMessage;
  final bool isLoadingMore;

  AnnouncementsListState copyWith({
    AnnouncementsListStatus? status,
    List<AnnouncementEntity>? items,
    AnnouncementUiFilter? filter,
    bool? hasMore,
    String? nextCursor,
    String? errorMessage,
    bool? isLoadingMore,
  }) {
    return AnnouncementsListState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor, // Allow null to clear cursor if needed, but usually we just pass the new one
      errorMessage: errorMessage, // Nullable to clear error
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    filter,
    hasMore,
    nextCursor,
    errorMessage,
    isLoadingMore,
  ];
}
