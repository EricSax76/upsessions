import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/announcement_card.dart';
import '../../../../core/widgets/layout/searchable_list_page.dart';
import '../../cubits/announcements_list_cubit.dart';
import '../../models/announcement_entity.dart';
import '../widgets/announcement_list/announcement_filter_panel.dart';
import '../widgets/announcement_list/announcements_hero_section.dart';
import '../widgets/announcement_list/announcements_list_footer.dart';

class AnnouncementsListPage extends StatelessWidget {
  const AnnouncementsListPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  void _openForm(BuildContext context) async {
    await context.push(AppRoutes.announcementForm);
    if (!context.mounted) return;
    context.read<AnnouncementsListCubit>().load(refresh: true);
  }

  Widget _buildFooter(BuildContext context, AnnouncementsListState state) {
    return AnnouncementsListFooter(
      isLoading: state.status == AnnouncementsListStatus.loading,
      isLoadingMore: state.isLoadingMore,
      hasMore: state.hasMore,
      isEmpty: state.items.isEmpty,
      errorMessage: state.errorMessage,
      loadMoreErrorMessage:
          state.status == AnnouncementsListStatus.success &&
                  !state.hasMore &&
                  state.errorMessage != null
              ? state.errorMessage
              : null,
      onRetryLoadMore: () => context.read<AnnouncementsListCubit>().loadMore(),
      onLoadMore: () => context.read<AnnouncementsListCubit>().loadMore(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnnouncementsListCubit(),
      child: Builder(
        builder: (context) {
          final listContent =
              BlocBuilder<AnnouncementsListCubit, AnnouncementsListState>(
                builder: (context, state) {
                  return SearchableListPage<AnnouncementEntity>(
                    items: state.items,
                    isLoading: state.status == AnnouncementsListStatus.loading,
                    errorMessage:
                        state.items.isEmpty ? state.errorMessage : null,
                    onRetry:
                        () => context.read<AnnouncementsListCubit>().load(
                          refresh: true,
                        ),
                    onRefresh:
                        () => context.read<AnnouncementsListCubit>().load(
                          refresh: true,
                        ),
                    searchEnabled: false,
                    gridLayout: true,
                    gridSpacing: 24,
                    emptyIcon: Icons.campaign_outlined,
                    emptyTitle: 'No hay anuncios',
                    emptySubtitle: 'Crea el primero o vuelve más tarde.',
                    headerBuilder:
                        !showAppBar
                            ? (_, _, _) => AnnouncementsHeroSection(
                              onNewAnnouncement: () => _openForm(context),
                            )
                            : null,
                    filterBuilder:
                        (_) => AnnouncementFilterPanel(
                          onChanged:
                              (filter) => context
                                  .read<AnnouncementsListCubit>()
                                  .setFilter(filter),
                        ),
                    footerBuilder: (_) => _buildFooter(context, state),
                    itemBuilder:
                        (announcement, index) => AnnouncementCard(
                          title: announcement.title,
                          subtitle:
                              '${announcement.city} · ${announcement.author}',
                          dateText:
                              '${announcement.publishedAt.day}/${announcement.publishedAt.month}',
                          onTap:
                              () => context.push(
                                AppRoutes.announcementDetailPath(
                                  announcement.id,
                                ),
                                extra: announcement,
                              ),
                        ),
                  );
                },
              );

          if (!showAppBar) {
            return SafeArea(child: listContent);
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Anuncios'),
              actions: [
                IconButton(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            body: listContent,
          );
        },
      ),
    );
  }
}
