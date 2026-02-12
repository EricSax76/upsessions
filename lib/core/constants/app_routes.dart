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
  static const musicianDetailRoute = '/musicians/:musicianId';
  static const musicianDetailLegacyRoute = '/musicians/:musicianId/:musicianName';
  static const announcements = '/announcements';
  static const announcementDetail = '/announcements/detail';
  static const announcementDetailRoute = '/announcements/:announcementId';
  static const announcementForm = '/announcements/form';
  static const media = '/media';
  static const messages = '/messages';
  static const messagesThreadRoute = '/messages/:threadId';
  static const messagesThreadDetailRoute = '/messages/thread/:threadId';
  static const contacts = '/contacts';
  static const calendar = '/calendar';
  static const events = '/events';
  static const eventDetail = '/events/detail';
  static const eventDetailRoute = '/events/:eventId';
  static const createEvent = '/events/create';
  static const rehearsals = '/rehearsals';
  static const invite = '/invite';
  static const inviteRoute = '/invite/:groupId/:inviteId';
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
  static const studiosProfile = '/studios/profile';
  static const studiosRoomsRoute = '/studios/:studioId/rooms';
  static const studiosRoomDetailRoute = '/studios/:studioId/rooms/:roomId';
  static const studiosRoomCreateRoute = '/studios/:studioId/rooms/new';
  static const studiosRoomEditRoute = '/studios/:studioId/rooms/:roomId/edit';
  static const myBookings = '/my-bookings';
  static const matching = '/matching';

  static const groupRoute = '/rehearsals/groups/:groupId';
  static const groupRehearsalsRoute = '/rehearsals/groups/:groupId/rehearsals';
  static const rehearsalDetailRoute =
      '/rehearsals/groups/:groupId/rehearsals/:rehearsalId';

  static String groupPage(String groupId) => '/rehearsals/groups/$groupId';

  static String rehearsalsGroup(String groupId) =>
      '/rehearsals/groups/$groupId';

  static String rehearsalsGroupRehearsals(String groupId) =>
      '/rehearsals/groups/$groupId/rehearsals';

  static String rehearsalDetail({
    required String groupId,
    required String rehearsalId,
  }) => '/rehearsals/groups/$groupId/rehearsals/$rehearsalId';

  static String musicianDetailPath({
    required String musicianId,
    required String musicianName,
  }) {
    final encodedId = Uri.encodeComponent(musicianId);
    return '/musicians/$encodedId';
  }

  static String announcementDetailPath(String announcementId) {
    final encodedId = Uri.encodeComponent(announcementId);
    return '/announcements/$encodedId';
  }

  static String eventDetailPath(String eventId) {
    final encodedId = Uri.encodeComponent(eventId);
    return '/events/$encodedId';
  }

  static String messagesThreadPath(String threadId) {
    final encodedId = Uri.encodeComponent(threadId);
    return '/messages/$encodedId';
  }

  static String messagesThreadDetailPath(String threadId) {
    final encodedId = Uri.encodeComponent(threadId);
    return '/messages/thread/$encodedId';
  }

  static String invitePath({
    required String groupId,
    required String inviteId,
  }) {
    final encodedGroupId = Uri.encodeComponent(groupId);
    final encodedInviteId = Uri.encodeComponent(inviteId);
    return '/invite/$encodedGroupId/$encodedInviteId';
  }

  static String studiosRoomsPath(String studioId) {
    final encodedStudioId = Uri.encodeComponent(studioId);
    return '/studios/$encodedStudioId/rooms';
  }

  static String studiosRoomDetailPath({
    required String studioId,
    required String roomId,
  }) {
    final encodedStudioId = Uri.encodeComponent(studioId);
    final encodedRoomId = Uri.encodeComponent(roomId);
    return '/studios/$encodedStudioId/rooms/$encodedRoomId';
  }

  static String studiosRoomCreatePath(String studioId) {
    final encodedStudioId = Uri.encodeComponent(studioId);
    return '/studios/$encodedStudioId/rooms/new';
  }

  static String studiosRoomEditPath({
    required String studioId,
    required String roomId,
  }) {
    final encodedStudioId = Uri.encodeComponent(studioId);
    final encodedRoomId = Uri.encodeComponent(roomId);
    return '/studios/$encodedStudioId/rooms/$encodedRoomId/edit';
  }
}
