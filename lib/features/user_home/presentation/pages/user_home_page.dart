import 'package:flutter/material.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/section_title.dart';
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
import '../widgets/profile/profile_link_box.dart';
import '../widgets/profile/profile_status_bar.dart';
import '../widgets/profile/quick_actions_row.dart';
import '../widgets/search/advanced_search_box.dart';
import '../widgets/sidebar/user_sidebar.dart';

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: const SmAppBar(),
          body: _controller.isLoading
              ? const LoadingIndicator()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: UserSidebar(
                        province: _controller.province,
                        city: _controller.city,
                        onProvinceChanged: _controller.selectProvince,
                        onCityChanged: _controller.selectCity,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MainNavBar(),
                            const SizedBox(height: 16),
                            const ProfileStatusBar(),
                            const SizedBox(height: 16),
                            const QuickActionsRow(),
                            const SizedBox(height: 24),
                            AdvancedSearchBox(
                              selectedInstrument: _controller.instrument,
                              selectedStyle: _controller.style,
                              selectedProfileType: _controller.profileType,
                              selectedGender: _controller.gender,
                              selectedProvince: _controller.province,
                              selectedCity: _controller.city,
                              onInstrumentChanged: _controller.selectInstrument,
                              onStyleChanged: _controller.selectStyle,
                              onProfileTypeChanged: _controller.selectProfileType,
                              onGenderChanged: _controller.selectGender,
                              onProvinceChanged: _controller.selectProvince,
                              onCityChanged: _controller.selectCity,
                            ),
                            const SizedBox(height: 24),
                            GlobalStatsRow(musicians: _controller.recommended.length, announcements: _controller.announcements.length),
                            const SizedBox(height: 32),
                            SectionTitle(text: 'Recomendados para ti', trailing: Text('${_controller.recommended.length} artistas')), 
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
                              builder: (announcement) => AnnouncementCard(announcement: announcement),
                            ),
                            const SizedBox(height: 32),
                            const ProfileLinkBox(),
                            const SizedBox(height: 32),
                            const ProvincesListSection(),
                            const SizedBox(height: 24),
                            const BottomCookieBar(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
