import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../controllers/user_home_controller.dart';
import 'package:upsessions/home/ui/widgets/announcements/announcement_card.dart';
import 'package:upsessions/home/ui/widgets/announcements/new_announcements_section.dart';
import 'package:upsessions/home/ui/widgets/events/upcoming_events_section.dart';
import 'package:upsessions/home/ui/widgets/footer/bottom_cookie_bar.dart';
import 'package:upsessions/home/ui/widgets/footer/provinces_list_section.dart';
import 'package:upsessions/home/ui/widgets/home_hero_banner.dart';
import 'package:upsessions/home/ui/widgets/home_section_card.dart';
import 'package:upsessions/home/ui/widgets/musicians/musicians_by_instrument_section.dart';
import 'package:upsessions/home/ui/widgets/musicians/new_musicians_section.dart';
import 'package:upsessions/home/ui/widgets/musicians/recommended_users_section.dart';
import 'package:upsessions/home/ui/widgets/profile/profile_status_bar.dart';
import 'package:upsessions/home/ui/pages/user_shell_page.dart';

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
    return UserShellPage(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: LoadingIndicator());
          }
          return _buildMainContent();
        },
      ),
    );
  }

  Widget _buildMainContent() {
    final stats = [
      HeroStatData(
        label: 'Eventos activos',
        value: '${_controller.events.length}',
        icon: Icons.event_available,
      ),
      HeroStatData(
        label: 'Nuevos anuncios',
        value: '${_controller.announcements.length}',
        icon: Icons.campaign_outlined,
      ),
      HeroStatData(
        label: 'Músicos conectados',
        value:
            '${_controller.recommended.length + _controller.newMusicians.length}',
        icon: Icons.people_alt,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        final colorScheme = Theme.of(context).colorScheme;
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
                    HomeHeroBanner(
                      title: 'Pasión por la música en vivo',
                      description:
                          'Conecta con artistas, agenda showcases híbridos y comparte tus proyectos en una plataforma diseñada para creadores.',
                      primaryActionLabel: 'Crear evento',
                      onPrimaryAction: () => context.push(AppRoutes.events),
                      secondaryActionLabel: 'Explorar músicos',
                      onSecondaryAction: () =>
                          context.push(AppRoutes.musicians),
                      stats: stats,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: ProfileStatusBar(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ..._buildResponsiveRow(
                      isWide,
                      HomeSectionCard(
                        title: 'Eventos próximos',
                        subtitle: 'Híbridos, residencias y sesiones íntimas',
                        action: TextButton.icon(
                          onPressed: () => context.push(AppRoutes.events),
                          icon: const Icon(Icons.arrow_outward),
                          label: const Text('Ver todos'),
                        ),
                        child: UpcomingEventsSection(
                          events: _controller.events,
                        ),
                      ),
                      HomeSectionCard(
                        title: 'Anuncios recientes',
                        subtitle:
                            'Colaboraciones y oportunidades publicadas hoy',
                        child: NewAnnouncementsSection(
                          announcements: _controller.announcements,
                          builder: (announcement) =>
                              AnnouncementCard(announcement: announcement),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ..._buildResponsiveRow(
                      isWide,
                      HomeSectionCard(
                        title: 'Recomendados para ti',
                        subtitle: 'Basado en tus estilos favoritos',
                        child: RecommendedUsersSection(
                          musicians: _controller.recommended,
                        ),
                      ),
                      HomeSectionCard(
                        title: 'Nuevos talentos',
                        subtitle: 'Músicos recién llegados a la comunidad',
                        child: NewMusiciansSection(
                          musicians: _controller.newMusicians,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    HomeSectionCard(
                      title: 'Explora por instrumento y región',
                      subtitle:
                          'Filtra por instrumento o provincia para encontrar a tu próximo colaborador.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MusiciansByInstrumentSection(
                            categories: _controller.categories,
                            musicians: _controller.recommended,
                            onInstrumentSelected: _controller.selectInstrument,
                          ),
                          const SizedBox(height: 24),
                          ProvincesListSection(
                            provinces: _controller.provinces,
                          ),
                        ],
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
