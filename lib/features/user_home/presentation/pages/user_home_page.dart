import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:upsessions/core/constants/app_routes.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../auth/application/auth_cubit.dart';
import '../../controllers/user_home_controller.dart';
import '../widgets/announcements/announcement_card.dart';
import '../widgets/announcements/new_announcements_section.dart';
import '../widgets/footer/bottom_cookie_bar.dart';
import '../widgets/footer/provinces_list_section.dart';
import '../widgets/header/global_stats_row.dart';
import '../widgets/header/main_nav_bar.dart';
import '../widgets/header/sm_app_bar.dart';
import '../widgets/musicians/musicians_by_instrument_section.dart';
import '../widgets/musicians/new_musicians_section.dart';
import '../widgets/musicians/recommended_users_section.dart';
import '../widgets/profile/profile_quick_actions_fab.dart';
import '../widgets/profile/profile_status_bar.dart';

import '../widgets/sidebar/user_sidebar.dart';
import 'home_tabs/secondary_tabs.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late final UserHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserHomeController();
    _controller.loadHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: MainNavBar.sections.length,
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          }
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final isWideLayout = MediaQuery.of(context).size.width >= 900;
            return Scaffold(
              appBar: const SmAppBar(bottom: MainNavBar()),
              drawer: isWideLayout
                  ? null
                  : Drawer(child: SafeArea(child: _buildSidebar())),
              body: _controller.isLoading
                  ? const LoadingIndicator()
                  : Stack(
                      children: [
                        TabBarView(
                          children: [
                            _buildResponsiveLayout(isWideLayout, _buildMainContent()),
                            _buildResponsiveLayout(isWideLayout, const MusiciansTab()),
                            _buildResponsiveLayout(isWideLayout, const AnnouncementsTab()),
                            _buildResponsiveLayout(isWideLayout, const MessagesTab()),
                            _buildResponsiveLayout(isWideLayout, const EventsTab()),
                          ],
                        ),
                        const Positioned(
                          right: 24,
                          bottom: 24,
                          child: SafeArea(child: ProfileQuickActionsFab()),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(bool isWideLayout, Widget content) {
    if (!isWideLayout) {
      return content;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 280, child: _buildSidebar()),
        const VerticalDivider(width: 1),
        Expanded(child: content),
      ],
    );
  }

  Widget _buildSidebar() {
    return const UserSidebar();
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const ProfileStatusBar(),
          const SizedBox(height: 24),
          const GlobalStatsRow(),
          const SizedBox(height: 32),
          SectionTitle(
            text: 'Recomendados para ti',
            trailing: Text('${_controller.recommended.length} artistas'),
          ),
          RecommendedUsersSection(musicians: _controller.recommended),
          const SizedBox(height: 24),
          SectionTitle(text: 'Nuevos talentos'),
          NewMusiciansSection(musicians: _controller.newMusicians),
          const SizedBox(height: 24),
          SectionTitle(text: 'Explora por instrumento'),
          MusiciansByInstrumentSection(
            categories: _controller.categories,
            musicians: _controller.recommended,
            onInstrumentSelected: _controller.selectInstrument,
          ),
          const SizedBox(height: 24),
          SectionTitle(text: 'Anuncios recientes'),
          NewAnnouncementsSection(
            announcements: _controller.announcements,
            builder: (announcement) =>
                AnnouncementCard(announcement: announcement),
          ),
          ProvincesListSection(provinces: _controller.provinces),
          const SizedBox(height: 24),
          const BottomCookieBar(),
        ],
      ),
    );
  }
}
