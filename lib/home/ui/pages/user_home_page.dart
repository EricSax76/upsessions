import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../cubits/user_home_cubit.dart';
import '../../cubits/user_home_state.dart';
import 'package:upsessions/core/widgets/announcement_card.dart';
import 'package:upsessions/home/ui/widgets/announcements/new_announcements_section.dart';
import 'package:upsessions/home/ui/widgets/events/upcoming_events_section.dart';
import 'package:upsessions/home/ui/widgets/footer/bottom_cookie_bar.dart';
import 'package:upsessions/home/ui/widgets/home_section_card.dart';
import 'package:upsessions/home/ui/widgets/musicians/musicians_by_instrument_section.dart';
import 'package:upsessions/home/ui/widgets/musicians/new_musicians_section.dart';
import 'package:upsessions/home/ui/widgets/musicians/recommended_users_section.dart';
import 'package:upsessions/home/ui/pages/user_shell_page.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserHomeCubit()..loadHome(),
      child: UserShellPage(
        child: BlocBuilder<UserHomeCubit, UserHomeState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: LoadingIndicator());
            }
            return _buildMainContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, UserHomeState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        final colorScheme = Theme.of(context).colorScheme;
        final cubit = context.read<UserHomeCubit>();
        final loc = AppLocalizations.of(context);
        return Container(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildResponsiveRow(
                      isWide,
                      HomeSectionCard(
                        title: loc.homeUpcomingEventsTitle,
                        action: TextButton.icon(
                          onPressed: () => context.push(AppRoutes.events),
                          icon: const Icon(Icons.arrow_outward),
                          label: Text(loc.viewAll),
                        ),
                        child: UpcomingEventsSection(
                          events: state.events,
                        ),
                      ),
                      HomeSectionCard(
                        title: loc.announcements,

                        child: NewAnnouncementsSection(
                          announcements: state.announcements,
                          builder: (announcement) =>
                              AnnouncementCard(
                                title: announcement.title,
                                subtitle:
                                    '${announcement.city} · ${announcement.description}',
                                dateText:
                                    '${announcement.date.day}/${announcement.date.month}',
                                dense: true,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ..._buildResponsiveRow(
                      isWide,
                      HomeSectionCard(
                        title: loc.homeRecommendedTitle,
                        subtitle: loc.homeRecommendedSubtitle,
                        child: RecommendedUsersSection(
                          musicians: state.recommended,
                        ),
                      ),
                      HomeSectionCard(
                        title: loc.homeNewTalentTitle,
                        subtitle: loc.homeNewTalentSubtitle,
                        action: TextButton.icon(
                          onPressed: () => context.push(AppRoutes.musicians),
                          icon: const Icon(Icons.arrow_outward),
                          label: Text(loc.viewAll),
                        ),
                        child: NewMusiciansSection(
                          musicians: state.newMusicians,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    HomeSectionCard(
                      title: loc.homeExploreByInstrumentTitle,
                      subtitle:
                          loc.homeExploreByInstrumentSubtitle,
                      action: TextButton.icon(
                        onPressed: () => context.push(AppRoutes.musicians),
                        icon: const Icon(Icons.arrow_outward),
                        label: Text(loc.viewAll),
                      ),
                      child: MusiciansByInstrumentSection(
                        categories: state.categories,
                        musicians: state.recommended,
                        onInstrumentSelected: cubit.selectInstrument,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const BottomCookieBar(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildResponsiveRow(bool isWide, Widget first, Widget second) {
    if (isWide) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 24),
            Expanded(child: second),
          ],
        ),
      ];
    }
    return [first, const SizedBox(height: 24), second];
  }
}
