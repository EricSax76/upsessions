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
import 'package:upsessions/core/widgets/section_card.dart';
import 'package:upsessions/home/ui/widgets/home_hero_section.dart';
import 'package:upsessions/home/ui/widgets/musicians/musicians_by_instrument_section.dart';
import 'package:upsessions/home/ui/widgets/musicians/new_musicians_section.dart';
import 'package:upsessions/home/ui/widgets/musicians/recommended_users_section.dart';
import 'package:upsessions/home/ui/pages/user_shell_page.dart';
import 'package:upsessions/home/ui/widgets/studios/studios_promo_card.dart';

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
        final width = constraints.maxWidth;
        final isWide = width >= 1200;
        final isMedium = width >= 800;
        final isCompact = width < 700;
        
        final colorScheme = Theme.of(context).colorScheme;
        final cubit = context.read<UserHomeCubit>();
        final loc = AppLocalizations.of(context);

        return Container(
          color: colorScheme.surfaceContainerLow,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: isWide ? 48 : 24,
              horizontal: isWide ? 48 : 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeroSection(
                      isCompact: isCompact,
                      upcomingRehearsals: state.upcomingRehearsals,
                    ),
                    const SizedBox(height: 48),
                    
                    if (isMedium) 
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildEventsSection(loc, state),
                                const SizedBox(height: 32),
                                _buildRecommendedSection(loc, state),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildAnnouncementsSection(loc, state),
                                const SizedBox(height: 32),
                                _buildNewTalentSection(loc, state),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildEventsSection(loc, state),
                          const SizedBox(height: 32),
                          _buildAnnouncementsSection(loc, state),
                          const SizedBox(height: 32),
                          _buildRecommendedSection(loc, state),
                          const SizedBox(height: 32),
                          _buildNewTalentSection(loc, state),
                        ],
                      ),

                    const SizedBox(height: 48),
                    SectionCard(
                      title: loc.studios, 
                      subtitle: loc.studiosSubtitle,
                      action: TextButton.icon(
                        onPressed: () => context.push(AppRoutes.studios),
                        icon: const Icon(Icons.arrow_outward),
                        label: Text(loc.viewAll),
                      ),
                      child: StudiosPromoCard(isCompact: isCompact),
                    ),
                    const SizedBox(height: 48),
                    SectionCard(
                      title: loc.homeExploreByInstrumentTitle,
                      subtitle: loc.homeExploreByInstrumentSubtitle,
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
                    const SizedBox(height: 48),
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

  Widget _buildEventsSection(AppLocalizations loc, UserHomeState state) {
    return Builder(
      builder: (context) => SectionCard(
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
    );
  }

  Widget _buildAnnouncementsSection(AppLocalizations loc, UserHomeState state) {
    return SectionCard(
      title: loc.announcements,
      child: NewAnnouncementsSection(
        announcements: state.announcements,
        builder: (announcement) => AnnouncementCard(
          title: announcement.title,
          subtitle: '${announcement.city} · ${announcement.description}',
          dateText: '${announcement.date.day}/${announcement.date.month}',
          dense: true,
        ),
      ),
    );
  }

  Widget _buildRecommendedSection(AppLocalizations loc, UserHomeState state) {
    return SectionCard(
      title: loc.homeRecommendedTitle,
      subtitle: loc.homeRecommendedSubtitle,
      child: RecommendedUsersSection(
        musicians: state.recommended,
      ),
    );
  }

  Widget _buildNewTalentSection(AppLocalizations loc, UserHomeState state) {
    return Builder(
      builder: (context) => SectionCard(
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
    );
  }
}
