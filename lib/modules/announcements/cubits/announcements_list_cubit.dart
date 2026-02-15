import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:upsessions/modules/announcements/models/announcement_entity.dart';
import 'package:upsessions/modules/announcements/repositories/announcements_repository.dart';
import 'package:upsessions/modules/announcements/ui/widgets/announcement_list/announcement_filter_panel.dart';

import '../../../../core/locator/locator.dart';

part 'announcements_list_state.dart';

class AnnouncementsListCubit extends Cubit<AnnouncementsListState> {
  AnnouncementsListCubit({
    AnnouncementsRepository? repository,
    bool autoLoad = true,
  })
    : _repository = repository ?? locate<AnnouncementsRepository>(),
      super(const AnnouncementsListState()) {
    if (autoLoad) {
      load(refresh: true);
    }
  }

  final AnnouncementsRepository _repository;
  static const _pageSize = 24;

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      if (state.status == AnnouncementsListStatus.loading) return;
      emit(state.copyWith(
        status: AnnouncementsListStatus.loading,
        items: [],
        nextCursor: null,
        hasMore: true,
        errorMessage: null,
      ));
    } else {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));
    }

    try {
      final filter = _mapFilter(state.filter);
      final page = await _repository.fetchPage(
        filter: filter,
        cursor: refresh ? null : state.nextCursor,
        limit: _pageSize,
      );

      final newItems =
          refresh
              ? page.items
              : <AnnouncementEntity>[...state.items, ...page.items];

      emit(
        state.copyWith(
          status: AnnouncementsListStatus.success,
          items: newItems,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              refresh
                  ? AnnouncementsListStatus.failure
                  : AnnouncementsListStatus.success, // Keep list if lazy load fails
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    await load(refresh: false);
  }

  void setFilter(AnnouncementUiFilter filter) {
    if (state.filter == filter) return;
    emit(state.copyWith(filter: filter));
    load(refresh: true);
  }

  AnnouncementFeedFilter _mapFilter(AnnouncementUiFilter filter) {
    switch (filter) {
      case AnnouncementUiFilter.nearby:
        return AnnouncementFeedFilter.nearby;
      case AnnouncementUiFilter.urgent:
        return AnnouncementFeedFilter.urgent;
      case AnnouncementUiFilter.all:
        return AnnouncementFeedFilter.all;
    }
  }
}
