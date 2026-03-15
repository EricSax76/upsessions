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
  String get providerGoogle => 'Google';

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
  String get eventsEmptyTitle => 'No events yet';

  @override
  String get eventsEmptyMessage =>
      'There are no events yet. Be the first to create one from the Events section.';

  @override
  String get announcementsEmptyTitle => 'No announcements yet';

  @override
  String get announcementsEmptySubtitle =>
      'Publish the first one or check back later.';

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
  String rehearsalsErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get rehearsalsGroupFallbackName => 'Group';

  @override
  String rehearsalsCreateError(String error) {
    return 'Could not create rehearsal: $error';
  }

  @override
  String get rehearsalsEmptyTitle => 'No rehearsals yet';

  @override
  String get rehearsalsEmptySubtitle =>
      'Create the first one to start building your setlist.';

  @override
  String get rehearsalsFilterEmptyTitle => 'No results';

  @override
  String get rehearsalsFilterEmptyUpcoming => 'No upcoming rehearsals.';

  @override
  String get rehearsalsFilterEmptyPast => 'No past rehearsals yet.';

  @override
  String get rehearsalsFilterEmptyAll => 'No rehearsals to show.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get saveAction => 'Save';

  @override
  String get closeAction => 'Close';

  @override
  String get doneAction => 'Done';

  @override
  String get removeAction => 'Remove';

  @override
  String get rehearsalsDeleteTitle => 'Delete rehearsal';

  @override
  String get rehearsalsDeleteMessage =>
      'The rehearsal and its setlist will be deleted. Continue?';

  @override
  String get rehearsalsDeleteSuccess => 'Rehearsal deleted.';

  @override
  String rehearsalsDeleteError(String error) {
    return 'Could not delete rehearsal: $error';
  }

  @override
  String get rehearsalsEditTitle => 'Edit rehearsal';

  @override
  String get rehearsalsUpdateSuccess => 'Rehearsal updated.';

  @override
  String rehearsalsUpdateError(String error) {
    return 'Could not update rehearsal: $error';
  }

  @override
  String setlistAddError(String error) {
    return 'Could not add item: $error';
  }

  @override
  String get setlistEditSongTitle => 'Edit song';

  @override
  String setlistUpdateError(String error) {
    return 'Could not update item: $error';
  }

  @override
  String get setlistDeleteItemTitle => 'Delete item';

  @override
  String setlistDeleteItemMessage(String itemTitle) {
    return 'Delete \"$itemTitle\" from the setlist?';
  }

  @override
  String setlistDeleteError(String error) {
    return 'Could not delete item: $error';
  }

  @override
  String get setlistCopyNoPrevious =>
      'There are no previous rehearsals to copy from.';

  @override
  String get setlistCopyDialogTitle => 'Copy setlist';

  @override
  String setlistCopyDialogMessage(String dateLabel) {
    return 'Copy the setlist from rehearsal $dateLabel to this rehearsal?';
  }

  @override
  String get setlistCopyAppendAction => 'Append at end';

  @override
  String get setlistCopyReplaceAction => 'Replace';

  @override
  String get setlistCopySuccess => 'Setlist copied.';

  @override
  String setlistCopyError(String error) {
    return 'Could not copy setlist: $error';
  }

  @override
  String setlistReorderError(String error) {
    return 'Could not reorder setlist: $error';
  }

  @override
  String get rehearsalDetailTitle => 'Rehearsal';

  @override
  String get rehearsalDetailDeleteTooltip => 'Delete rehearsal';

  @override
  String get rehearsalDetailSetlistEmpty => 'No songs in this setlist';

  @override
  String rehearsalDetailSetlistTitle(int count) {
    return 'Setlist ($count)';
  }

  @override
  String get rehearsalDetailCopyPreviousAction => 'Copy from previous';

  @override
  String get rehearsalDetailAddSongAction => 'Add song';

  @override
  String get rehearsalDetailInfoTitle => 'Details';

  @override
  String get rehearsalDetailStartLabel => 'Start';

  @override
  String get rehearsalDetailEndLabel => 'End';

  @override
  String get rehearsalDetailLocationLabel => 'Location';

  @override
  String get rehearsalDetailRoomTitle => 'Rehearsal Room';

  @override
  String get rehearsalDetailBookRoomAction => 'Book';

  @override
  String get rehearsalDetailNoRoomBooked => 'No room booked';

  @override
  String get rehearsalDetailRoomConfirmed => 'Confirmed';

  @override
  String get rehearsalDetailNotesTitle => 'Notes';

  @override
  String get setlistTableHeaderTitle => 'Title';

  @override
  String get setlistTableHeaderKey => 'Key';

  @override
  String get setlistTableHeaderBpm => 'BPM';

  @override
  String get setlistTableHeaderNotes => 'Notes';

  @override
  String get setlistTableUntitledSong => 'Untitled';

  @override
  String get setlistTableDeleteTooltip => 'Remove from setlist';

  @override
  String get setlistTableBpmUnit => 'BPM';

  @override
  String get setlistItemAddSongTitle => 'Add song';

  @override
  String get setlistItemAddAction => 'Add';

  @override
  String get setlistItemSongLabel => 'Song';

  @override
  String get setlistItemSongHint => 'e.g. Autumn Leaves';

  @override
  String get setlistItemKeyLabel => 'Key';

  @override
  String get setlistItemTempoLabel => 'Tempo (bpm)';

  @override
  String get setlistItemOrderLabel => 'Order';

  @override
  String get setlistItemNotesLabel => 'Notes';

  @override
  String get setlistItemLinkLabel => 'Link (YouTube, etc.)';

  @override
  String get setlistItemLinkHint => 'https://...';

  @override
  String get setlistItemSheetSelected => 'Sheet selected';

  @override
  String get setlistItemUploadSheet => 'Upload sheet';

  @override
  String get rehearsalDialogPickDateTime => 'Pick date/time';

  @override
  String get rehearsalDialogOptional => 'Optional';

  @override
  String get rehearsalDialogNewTitle => 'New rehearsal';

  @override
  String get rehearsalDialogStartLabel => 'Start';

  @override
  String get rehearsalDialogEndLabel => 'End';

  @override
  String get rehearsalDialogRemoveEndTooltip => 'Clear end';

  @override
  String get rehearsalDialogLocationLabel => 'Location';

  @override
  String get rehearsalDialogLocationHint => 'e.g. Room 2 / Studio';

  @override
  String get rehearsalDialogNotesLabel => 'Notes';

  @override
  String get rehearsalDialogNotesHint => 'e.g. Bring metronome';

  @override
  String get rehearsalDialogCreateAction => 'Create';

  @override
  String get rehearsalDialogEndBeforeStartError =>
      'End time cannot be before start time.';

  @override
  String get inviteDialogTitle => 'Add musician';

  @override
  String get inviteSearchLabel => 'Search by name';

  @override
  String get inviteSearchHint => 'e.g. ana';

  @override
  String get inviteTypeAtLeastOneCharacter => 'Type at least 1 character.';

  @override
  String get inviteNoResults => 'No results.';

  @override
  String get inviteCreatedTitle => 'Invitation created';

  @override
  String inviteCreatedFor(String name) {
    return 'For: $name';
  }

  @override
  String get inviteCopyLinkAction => 'Copy link';

  @override
  String get inviteLinkCopied => 'Link copied.';

  @override
  String inviteCreateError(String error) {
    return 'Could not create invitation: $error';
  }

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
  String get studios => 'Rehearsal rooms';

  @override
  String get studiosSubtitle => 'Book the ideal space for your band';

  @override
  String get studiosDashboard => 'Studio management';

  @override
  String get studiosManage => 'Manage studio';

  @override
  String get studiosRegister => 'Register studio';

  @override
  String get studiosCreateTitle => 'Register studio';

  @override
  String get studiosCreateSectionStudioData => 'Studio data';

  @override
  String get studiosCreateSectionLocation => 'Location';

  @override
  String get studiosCreateSectionFiscal => 'Tax and administrative compliance';

  @override
  String get studiosCreateSectionAccessibility => 'Accessibility and insurance';

  @override
  String get studiosCreateAction => 'Create studio';

  @override
  String get studiosCreateSuccess => 'Studio created successfully.';

  @override
  String get studiosCreateAuthRequired =>
      'You must sign in to create a studio.';

  @override
  String get studiosCreateInsuranceDateRequired =>
      'Select the liability insurance expiry date.';

  @override
  String get studiosCreateMaxCapacityInvalid =>
      'Invalid max capacity (must be > 0).';

  @override
  String get studioProfileUpdateSuccess => 'Profile updated successfully.';

  @override
  String get studioProfileUpdateError => 'Could not save changes.';

  @override
  String get studioProfileImagesUpdateError => 'Could not update images.';

  @override
  String get studioProfileNotFound => 'No studio found.';

  @override
  String get studioDashboardTabRooms => 'My rooms';

  @override
  String get studioDashboardTabBookings => 'Bookings';

  @override
  String get studioDashboardRoomsTitle => 'My rooms';

  @override
  String get studioDashboardAddRoom => 'Add room';

  @override
  String get studioDashboardLoadMoreBookings => 'Load more bookings';

  @override
  String studioDashboardBookingTotal(String total) {
    return 'Total: $total€';
  }

  @override
  String studioDashboardRoomSummary(String capacity, String price) {
    return '$capacity people • $price€/hour';
  }

  @override
  String get studioSidebarManagementTitle => 'STUDIO MANAGEMENT';

  @override
  String get studioSidebarFallbackName => 'My studio';

  @override
  String get studioSidebarSessionLabel => 'Studio session';

  @override
  String get studioSidebarMenuDashboard => 'Dashboard';

  @override
  String get studioSidebarMenuBookings => 'My bookings';

  @override
  String get studioSidebarMenuRooms => 'My rooms';

  @override
  String get studioSidebarMenuProfile => 'Studio profile';

  @override
  String get studioSidebarLogout => 'Sign out';

  @override
  String get studioSidebarThemeLight => 'Light mode';

  @override
  String get studioSidebarThemeDark => 'Dark mode';

  @override
  String get studioEmptyNoStudioTitle =>
      'You have not registered your studio yet';

  @override
  String get studioEmptyNoStudioSubtitle =>
      'Create your studio profile to start receiving bookings';

  @override
  String get studioEmptyNoStudioAction => 'Register studio';

  @override
  String get studioEmptyNoRoomsTitle => 'You have no registered rooms';

  @override
  String get studioEmptyNoRoomsSubtitle =>
      'Add your first room to start receiving bookings';

  @override
  String get studioEmptyNoBookingsTitle => 'No pending bookings';

  @override
  String get studioEmptyNoBookingsSubtitle => 'Your bookings will appear here';

  @override
  String get roomFormAddTitle => 'Add room';

  @override
  String get roomFormEditTitle => 'Edit room';

  @override
  String get roomFormNameLabel => 'Room name';

  @override
  String get roomFormCapacityLabel => 'Capacity (people)';

  @override
  String get roomFormSizeLabel => 'Size (e.g. 4x5m)';

  @override
  String get roomFormPricePerHourLabel => 'Price per hour (€)';

  @override
  String get roomFormEquipmentLabel => 'Equipment (comma separated)';

  @override
  String get roomFormRequiredField => 'Required field';

  @override
  String get roomFormSectionConfig => 'Room settings';

  @override
  String get roomFormMinBookingHoursLabel => 'Minimum booking hours';

  @override
  String get roomFormMinBookingHoursHelp =>
      'Contractual — minimum number of hours';

  @override
  String get roomFormMaxDecibelsLabel => 'Maximum decibels (dB)';

  @override
  String get roomFormMaxDecibelsHelp => 'Local noise ordinance — max level';

  @override
  String get roomFormAgeRestrictionLabel => 'Minimum age restriction';

  @override
  String get roomFormAgeRestrictionHelp =>
      'LOPDGDD Art. 7 — minimum age to use the room';

  @override
  String get roomFormSectionPolicies => 'Policies';

  @override
  String get roomFormCancellationPolicyLabel => 'Cancellation policy';

  @override
  String get roomFormCancellationPolicyHelp =>
      'Directive 2011/83/EU — cancellation and refund';

  @override
  String get roomFormAccessibleTitle => 'Accessibility';

  @override
  String get roomFormAccessibleSubtitle =>
      'RD 1/2013 — reduced mobility access';

  @override
  String get roomFormActiveTitle => 'Room active';

  @override
  String get roomFormActiveSubtitle => 'Visible for bookings';

  @override
  String get roomFormCreateAction => 'Create room';

  @override
  String get roomFormSaveError => 'Error saving room.';

  @override
  String get roomFormPhotosTitle => 'Photos';

  @override
  String get roomFormAttachPhotos => 'Attach photos';

  @override
  String get studiosListTitleForRehearsal => 'Book room for rehearsal';

  @override
  String get studiosListEmpty => 'No studios available.';

  @override
  String get studiosListLoadMore => 'Load more studios';

  @override
  String get studioRoomsTitle => 'Studio rooms';

  @override
  String get studioRoomsEmpty => 'No rooms available in this studio.';

  @override
  String get musicianBookingsLoginRequired =>
      'Please sign in to view bookings.';

  @override
  String get musicianBookingsLoadError => 'Could not load bookings.';

  @override
  String get musicianBookingsRetry => 'Retry';

  @override
  String get musicianBookingsEmpty => 'No bookings found.';

  @override
  String get musicianBookingsTitle => 'MY BOOKINGS';

  @override
  String get musicianBookingsUpcoming => 'Upcoming bookings';

  @override
  String get musicianBookingsHistory => 'History';

  @override
  String get musicianBookingsLoadMore => 'Load more bookings';

  @override
  String get bookingStatusConfirmed => 'confirmed';

  @override
  String get bookingStatusCancelled => 'cancelled';

  @override
  String get bookingStatusRefunded => 'refunded';

  @override
  String get bookingStatusPending => 'pending';

  @override
  String roomCardPricePerHour(String price) {
    return '$price€ /h';
  }

  @override
  String roomCardCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# people',
      one: '# person',
    );
    return '$_temp0';
  }

  @override
  String get studioCardViewRooms => 'View rooms';

  @override
  String get eventsNewEventButton => 'New event';

  @override
  String get eventsViewDetails => 'View details';

  @override
  String get eventsViewTextSheet => 'View text sheet';

  @override
  String get eventsCopyFormat => 'Copy format';

  @override
  String get eventsCopySheetTooltip => 'Copy sheet';

  @override
  String get onboardingInfluencesTitle => 'Your influences';

  @override
  String get onboardingInfluencesDescription =>
      'Add the bands or artists that influenced you the most, organized by style.';

  @override
  String get onboardingInfluencesEmpty => 'You have not added influences yet.';

  @override
  String get affinityStyleLabel => 'Style';

  @override
  String get affinityArtistBandLabel => 'Artist / Band';

  @override
  String get affinitySuggestedOptionsLabel => 'Suggested options';

  @override
  String get affinityNoMatchesForStyle => 'No matches for this style.';

  @override
  String get affinityAddButton => 'Add';

  @override
  String get affinityAddTooltip => 'Add affinity';

  @override
  String get profileAffinityTitle => 'Music affinities';

  @override
  String get profileAffinityDescription =>
      'Add or remove artists that represent your influences by style.';

  @override
  String get profileAffinityEmpty => 'No affinities registered.';

  @override
  String roomDetailPricePerHour(String price) {
    return '$price€ / hour';
  }

  @override
  String roomDetailCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Capacity: # people',
      one: 'Capacity: # person',
    );
    return '$_temp0';
  }

  @override
  String roomDetailSize(String size) {
    return 'Size: $size';
  }

  @override
  String get roomDetailEquipmentTitle => 'Equipment';

  @override
  String get roomDetailBookForRehearsal => 'Book for rehearsal';

  @override
  String get roomDetailBookRoom => 'Book room';

  @override
  String roomDetailBookingSuccessForRehearsal(String total) {
    return 'Room booked for rehearsal for $total€.';
  }

  @override
  String roomDetailBookingSuccess(String total) {
    return 'Booking confirmed for $total€.';
  }

  @override
  String get roomDetailBookingError => 'Could not complete booking.';

  @override
  String get roomDetailPrefilledFromRehearsal =>
      'Date and time pre-filled from rehearsal';

  @override
  String get roomDetailDateLabel => 'Date';

  @override
  String get roomDetailSelectDate => 'Select date';

  @override
  String get roomDetailStartTimeLabel => 'Start time';

  @override
  String get roomDetailSelectTime => 'Select time';

  @override
  String roomDetailDurationHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Duration: # hours',
      one: 'Duration: # hour',
    );
    return '$_temp0';
  }

  @override
  String roomDetailMinBookingHours(int hours) {
    return 'Minimum booking: ${hours}h';
  }

  @override
  String roomDetailMaxDecibels(String decibels) {
    return 'Max decibels: $decibels dB';
  }

  @override
  String roomDetailMinimumAge(int age) {
    return 'Minimum age: $age years';
  }

  @override
  String get roomDetailAccessibleMobility => 'Accessible for reduced mobility';

  @override
  String get roomDetailCancellationPolicyTitle => 'Cancellation policy';

  @override
  String get roomDetailPaymentMethodLabel => 'Payment method';

  @override
  String get roomDetailVatLabel => 'VAT (21%):';

  @override
  String get paymentMethodCard => 'Card';

  @override
  String get paymentMethodTransfer => 'Transfer';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodBizum => 'Bizum';

  @override
  String get roomDetailTotalPriceLabel => 'Total price:';

  @override
  String get roomDetailConfirmBookingForRehearsal => 'Confirm booking';

  @override
  String get roomDetailConfirmBooking => 'Confirm booking';

  @override
  String get homeExploreLabel => 'Explore';

  @override
  String get homeGreetingSubtitle => 'Here\'s your summary for today';
}
