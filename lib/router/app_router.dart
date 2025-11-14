import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../features/announcements/data/announcements_repository.dart';
import '../features/announcements/domain/announcement_entity.dart';
import '../features/announcements/presentation/pages/announcement_detail_page.dart';
import '../features/announcements/presentation/pages/announcement_form_page.dart';
import '../features/announcements/presentation/pages/announcements_list_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/media/presentation/pages/media_gallery_page.dart';
import '../features/messaging/presentation/pages/chat_page.dart';
import '../features/musicians/domain/musician_entity.dart';
import '../features/musicians/presentation/pages/musician_detail_page.dart';
import '../features/musicians/presentation/pages/musician_search_page.dart';
import '../features/profile/presentation/pages/account_page.dart';
import '../features/profile/presentation/pages/profile_edit_page.dart';
import '../features/profile/presentation/pages/profile_overview_page.dart';
import '../features/settings/presentation/pages/help_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/user_home/presentation/pages/user_home_page.dart';

class AppRouter {
  AppRouter();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage(), settings: settings);
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage(), settings: settings);
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage(), settings: settings);
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage(), settings: settings);
      case AppRoutes.userHome:
        return MaterialPageRoute(builder: (_) => const UserHomePage(), settings: settings);
      case AppRoutes.musicians:
        return MaterialPageRoute(builder: (_) => const MusicianSearchPage(), settings: settings);
      case AppRoutes.musicianDetail:
        final musician = settings.arguments;
        if (musician is MusicianEntity) {
          return MaterialPageRoute(
            builder: (_) => MusicianDetailPage(musician: musician),
            settings: settings,
          );
        }
        break;
      case AppRoutes.announcements:
        return MaterialPageRoute(builder: (_) => const AnnouncementsListPage(), settings: settings);
      case AppRoutes.announcementDetail:
        final announcement = settings.arguments;
        if (announcement is AnnouncementEntity) {
          return MaterialPageRoute(
            builder: (_) => AnnouncementDetailPage(announcement: announcement),
            settings: settings,
          );
        }
        break;
      case AppRoutes.announcementForm:
        return MaterialPageRoute(
          builder: (_) => AnnouncementFormPage(repository: AnnouncementsRepository()),
          settings: settings,
        );
      case AppRoutes.media:
        return MaterialPageRoute(builder: (_) => const MediaGalleryPage(), settings: settings);
      case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => const ChatPage(), settings: settings);
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileOverviewPage(), settings: settings);
      case AppRoutes.profileEdit:
        return MaterialPageRoute(builder: (_) => const ProfileEditPage(), settings: settings);
      case AppRoutes.account:
        return MaterialPageRoute(builder: (_) => const AccountPage(), settings: settings);
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage(), settings: settings);
      case AppRoutes.help:
        return MaterialPageRoute(builder: (_) => const HelpPage(), settings: settings);
    }

    return MaterialPageRoute(
      builder: (context) => _UnknownRouteScreen(name: settings.name ?? 'unknown'),
      settings: settings,
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta no encontrada'),
      ),
      body: Center(
        child: Text('La ruta "$name" no existe.'),
      ),
    );
  }
}
