// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'UPSESSIONS';

  @override
  String get welcome => 'Welcome to the music community.';

  @override
  String get searchMusicians => 'Find musicians and bands across the country.';

  @override
  String get announcements => 'Recent announcements';

  @override
  String get profile => 'Your musical profile';

  @override
  String get appBrandName => 'UPSESSIONS';

  @override
  String get appWelcomeTagline => 'Connect your music\nwithout limits.';

  @override
  String get startButton => 'Get started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get login => 'Sign in';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get createAccount => 'Create account';

  @override
  String get registerPageSubtitle => 'Join the Solo Musicians network';

  @override
  String get registerPageLoginPrompt => 'Already have an account? Sign in';

  @override
  String get loginContinueWith => 'Or continue with';

  @override
  String continueWithProvider(String provider) {
    return 'Continue with $provider';
  }

  @override
  String socialLoginPlaceholder(String provider) {
    return '$provider login is coming soon.';
  }

  @override
  String get providerEmail => 'Email';

  @override
  String get providerFacebook => 'Facebook';

  @override
  String get providerApple => 'Apple';

  @override
  String get emailHint => 'Email address';

  @override
  String get emailRequired => 'Enter your email';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordToggleShow => 'Show password';

  @override
  String get passwordToggleHide => 'Hide password';

  @override
  String get passwordTooShort => 'Password must have at least 4 characters';

  @override
  String get onboardingCollaborateTitle => 'Connect with real musicians';

  @override
  String get onboardingCollaborateDescription =>
      'Discover instrumentalists and producers available for live or remote sessions.';

  @override
  String get onboardingShowcaseTitle => 'Showcase your talent';

  @override
  String get onboardingShowcaseDescription => 'Share your music';

  @override
  String get onboardingBookTitle => 'Your music booking hub';

  @override
  String get onboardingBookDescription =>
      'Coordinate availability, contracts, and payments in a few clicks.';

  @override
  String get eventsShowcasesTitle => 'Events and showcases';

  @override
  String get eventsShowcasesDescription =>
      'Plan your sessions. Generate a text sheet to share by email or chat.';

  @override
  String get eventsActiveLabel => 'Active events';

  @override
  String get eventsThisWeekLabel => 'This week';

  @override
  String get eventsTotalCapacityLabel => 'Total capacity';

  @override
  String get eventsEmptyMessage =>
      'There are no events yet. Be the first to create one from the Events section.';

  @override
  String get noEventsOnDate => 'There are no events scheduled for this date.';

  @override
  String get navMusicians => 'Musicians';

  @override
  String get navAnnouncements => 'Announcements';

  @override
  String get navEvents => 'Events';

  @override
  String get navRehearsals => 'Rehearsals';

  @override
  String get rehearsalsPageSubtitle => 'Manage your group rehearsals';

  @override
  String get rehearsalsSummaryTitle => 'Summary';

  @override
  String rehearsalsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# scheduled rehearsals',
      one: '1 scheduled rehearsal',
    );
    return '$_temp0';
  }

  @override
  String get rehearsalsNextLabel => 'Next';

  @override
  String get rehearsalsTotalStat => 'Total Rehearsals';

  @override
  String get rehearsalsNoUpcoming => 'Not scheduled';

  @override
  String get rehearsalsNewButton => 'New Rehearsal';

  @override
  String get rehearsalsAddMusicianButton => 'Add Musician';

  @override
  String get rehearsalsOnlyAdmin => 'Only Admin';

  @override
  String get rehearsalsFilterUpcoming => 'Upcoming';

  @override
  String get rehearsalsFilterPast => 'Past';

  @override
  String get rehearsalsFilterAll => 'All';

  @override
  String get musicianContactTitle => 'Interested in collaborating?';

  @override
  String get musicianContactDescription =>
      'Connect by chat to coordinate details and availability.';

  @override
  String get musicianContactLoading => 'Opening...';

  @override
  String get musicianContactButton => 'Contact';

  @override
  String get musicianInviteButton => 'Invite';

  @override
  String eventsForDate(String dateLabel) {
    return 'Events for $dateLabel';
  }

  @override
  String eventsPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# people',
      one: '# person',
    );
    return '$_temp0';
  }

  @override
  String get rehearsalsGroupsMyGroupsTab => 'My Groups';

  @override
  String get rehearsalsGroupsAgendaTab => 'Agenda';

  @override
  String get rehearsalsGroupsErrorLoading => 'We could not load your groups.';

  @override
  String get rehearsalsGroupsRetryButton => 'Retry';

  @override
  String rehearsalsGroupsCreateGroupError(String error) {
    return 'Could not create group: $error';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get error => 'Error';

  @override
  String get rehearsalsGroupsAgendaNoRehearsalsTitle => 'No rehearsals yet';

  @override
  String get rehearsalsGroupsAgendaNoRehearsalsSubtitle =>
      'Here you will see your upcoming rehearsals from all your groups.';

  @override
  String get homeUpcomingEventsTitle => 'Upcoming events';

  @override
  String get homeNextRehearsalLabel => 'Next rehearsal';

  @override
  String get homeNextRehearsalFallbackTitle => 'Scheduled rehearsal';

  @override
  String get viewAll => 'View all';

  @override
  String get homeRecommendedTitle => 'Recommended for you';

  @override
  String get homeRecommendedSubtitle => 'Based on your favorite styles';

  @override
  String get homeNewTalentTitle => 'New talent';

  @override
  String get homeNewTalentSubtitle =>
      'Musicians newly arrived to the community';

  @override
  String get homeExploreByInstrumentTitle => 'Explore by instrument';

  @override
  String get homeExploreByInstrumentSubtitle =>
      'Filter by instrument to find your next collaborator.';

  @override
  String rehearsalsSidebarErrorLoading(String error) {
    return 'Error loading groups: $error';
  }

  @override
  String get rehearsalsSidebarNewGroupLabel => 'New group';

  @override
  String get rehearsalsSidebarEmptyPrompt => 'Create a group to get started.';

  @override
  String rehearsalsSidebarRoleLabel(String role) {
    return 'Role: $role';
  }

  @override
  String get rehearsalsSidebarCreateGroupTitle => 'Create group';

  @override
  String get rehearsalsSidebarGroupNameLabel => 'Name';

  @override
  String get rehearsalsSidebarGroupNameHint => 'e.g. Band X';

  @override
  String get create => 'Create';

  @override
  String get userSidebarTitle => 'Your dashboard';

  @override
  String get searchAdvancedTitle => 'Advanced search';

  @override
  String get searchFiltersTitle => 'Filters';

  @override
  String searchFiltersWithCount(int count) {
    return 'Filters ($count)';
  }

  @override
  String get searchTopBarHint => 'Search by name, style, or instrument';

  @override
  String get searchInstrumentLabel => 'Instrument';

  @override
  String get searchInstrumentHint => 'Select instrument';

  @override
  String get searchStyleLabel => 'Style';

  @override
  String get searchStyleHint => 'Select style';

  @override
  String get searchProfileTypeLabel => 'Profile type';

  @override
  String get searchProfileTypeHint => 'Select type';

  @override
  String get searchProvinceLabel => 'Province';

  @override
  String get searchProvinceHint => 'Select province';

  @override
  String get searchCityLabel => 'City';

  @override
  String get searchCityHint => 'Select city';

  @override
  String get searchCityUnavailable => 'No cities available';

  @override
  String get searchClearFilters => 'Clear filters';

  @override
  String get searchAction => 'Search';

  @override
  String get searchGenderLabel => 'Gender';

  @override
  String get searchGenderHint => 'Select gender';

  @override
  String get searchUnassignedOption => 'Unassigned';

  @override
  String get searchAnyOption => 'Any';

  @override
  String get searchFemaleOption => 'Female';

  @override
  String get searchMaleOption => 'Male';

  @override
  String get searchAdvancedFiltersTitle => 'Advanced filters';

  @override
  String get searchAdvancedFiltersSubtitle => 'Tap to adjust filters';

  @override
  String get searchProvincesLoadHint =>
      'Load Spanish provinces from Firestore (metadata/geography.provinces).';

  @override
  String get searchCitiesLoadHint =>
      'Add cities per province in Firestore (metadata/geography.citiesByProvince).';

  @override
  String get studios => 'Salas de Ensayo';

  @override
  String get studiosSubtitle => 'Reserva el espacio ideal para tu banda';

  @override
  String get studiosDashboard => 'Gestión de Sala';

  @override
  String get studiosManage => 'Gestionar Sala';

  @override
  String get studiosRegister => 'Registrar Sala';
}
