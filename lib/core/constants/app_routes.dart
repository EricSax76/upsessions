import 'package:flutter/foundation.dart';

class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const onboardingStoryOne = '/onboarding/story-one';
  static const onboardingStoryTwo = '/onboarding/story-two';
  static const onboardingStoryThree = '/onboarding/story-three';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const musicianOnboarding = '/onboarding/musician';
  static const userHome = '/home';
  static const musicians = '/musicians';
  static const musicianDetail = '/musicians/detail';
  static const musicianDetailRoute = '/musicians/:musicianId/:musicianName';
  static const announcements = '/announcements';
  static const announcementDetail = '/announcements/detail';
  static const announcementDetailRoute = '/announcements/:announcementId';
  static const announcementForm = '/announcements/form';
  static const media = '/media';
  static const messages = '/messages';
  static const contacts = '/contacts';
  static const calendar = '/calendar';
  static const events = '/events';
  static const eventDetail = '/events/detail';
  static const eventDetailRoute = '/events/:eventId';
  static const createEvent = '/events/create';
  static const rehearsals = '/rehearsals';
  static const invite = '/invite';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const account = '/profile/account';
  static const settings = '/settings';
  static const help = '/settings/help';
  static const notifications = '/notifications';
  
  static const studios = '/studios';
  static const studiosLogin = '/studios/login';
  static const studiosRegister = '/studios/register';
  static const studiosCreate = '/studios/create';
  static const studiosDashboard = '/studios/dashboard';
  static const myBookings = '/bookings';

  static const groupRoute = '/rehearsals/groups/:groupId';
  static const groupRehearsalsRoute =
      '/rehearsals/groups/:groupId/rehearsals';
  static const rehearsalDetailRoute =
      '/rehearsals/groups/:groupId/rehearsals/:rehearsalId';

  static String groupPage(String groupId) => '/rehearsals/groups/$groupId';

  static String rehearsalsGroup(String groupId) => '/rehearsals/groups/$groupId';

  static String rehearsalsGroupRehearsals(String groupId) =>
      '/rehearsals/groups/$groupId/rehearsals';

  static String rehearsalDetail({
    required String groupId,
    required String rehearsalId,
  }) =>
      '/rehearsals/groups/$groupId/rehearsals/$rehearsalId';

  static String musicianDetailPath({
    required String musicianId,
    required String musicianName,
  }) {
    if (!kIsWeb) {
      return musicianDetail;
    }
    final encodedId = Uri.encodeComponent(musicianId);
    final slug = _slugify(musicianName);
    return '/musicians/$encodedId/$slug';
  }

  static String announcementDetailPath(String announcementId) {
    if (!kIsWeb) {
      return announcementDetail;
    }
    final encodedId = Uri.encodeComponent(announcementId);
    return '/announcements/$encodedId';
  }

  static String eventDetailPath(String eventId) {
    if (!kIsWeb) {
      return eventDetail;
    }
    final encodedId = Uri.encodeComponent(eventId);
    return '/events/$encodedId';
  }

  static String _slugify(String input) {
    final trimmed = input.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return 'musician';
    }
    final dashed = trimmed.replaceAll(RegExp(r'\s+'), '-');
    return Uri.encodeComponent(dashed);
  }
}
