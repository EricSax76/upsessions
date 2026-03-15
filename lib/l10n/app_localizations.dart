import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  String get appName;

  String get welcome;

  String get searchMusicians;

  String get announcements;

  String get profile;

  String get appBrandName;

  String get appWelcomeTagline;

  String get startButton;

  String get skip;

  String get next;

  String get login;

  String get forgotPassword;

  String get createAccount;

  String get registerPageSubtitle;

  String get registerPageLoginPrompt;

  String get loginContinueWith;

  String continueWithProvider(String provider);

  String socialLoginPlaceholder(String provider);

  String get providerEmail;

  String get providerGoogle;

  String get providerFacebook;

  String get providerApple;

  String get emailHint;

  String get emailRequired;

  String get emailInvalid;

  String get passwordHint;

  String get passwordToggleShow;

  String get passwordToggleHide;

  String get passwordTooShort;

  String get onboardingCollaborateTitle;

  String get onboardingCollaborateDescription;

  String get onboardingShowcaseTitle;

  String get onboardingShowcaseDescription;

  String get onboardingBookTitle;

  String get onboardingBookDescription;

  String get eventsShowcasesTitle;

  String get eventsShowcasesDescription;

  String get eventsActiveLabel;

  String get eventsThisWeekLabel;

  String get eventsTotalCapacityLabel;

  String get eventsEmptyTitle;

  String get eventsEmptyMessage;

  String get announcementsEmptyTitle;

  String get announcementsEmptySubtitle;

  String get noEventsOnDate;

  String get navMusicians;

  String get navAnnouncements;

  String get navEvents;

  String get navRehearsals;

  String get rehearsalsPageSubtitle;

  String get rehearsalsSummaryTitle;

  String rehearsalsTotalCount(int count);

  String get rehearsalsNextLabel;

  String get rehearsalsTotalStat;

  String get rehearsalsNoUpcoming;

  String get rehearsalsNewButton;

  String get rehearsalsAddMusicianButton;

  String get rehearsalsOnlyAdmin;

  String get rehearsalsFilterUpcoming;

  String get rehearsalsFilterPast;

  String get rehearsalsFilterAll;

  String rehearsalsErrorWithMessage(String message);

  String get rehearsalsGroupFallbackName;

  String rehearsalsCreateError(String error);

  String get rehearsalsEmptyTitle;

  String get rehearsalsEmptySubtitle;

  String get rehearsalsFilterEmptyTitle;

  String get rehearsalsFilterEmptyUpcoming;

  String get rehearsalsFilterEmptyPast;

  String get rehearsalsFilterEmptyAll;

  String get deleteAction;

  String get saveAction;

  String get closeAction;

  String get doneAction;

  String get removeAction;

  String get rehearsalsDeleteTitle;

  String get rehearsalsDeleteMessage;

  String get rehearsalsDeleteSuccess;

  String rehearsalsDeleteError(String error);

  String get rehearsalsEditTitle;

  String get rehearsalsUpdateSuccess;

  String rehearsalsUpdateError(String error);

  String setlistAddError(String error);

  String get setlistEditSongTitle;

  String setlistUpdateError(String error);

  String get setlistDeleteItemTitle;

  String setlistDeleteItemMessage(String itemTitle);

  String setlistDeleteError(String error);

  String get setlistCopyNoPrevious;

  String get setlistCopyDialogTitle;

  String setlistCopyDialogMessage(String dateLabel);

  String get setlistCopyAppendAction;

  String get setlistCopyReplaceAction;

  String get setlistCopySuccess;

  String setlistCopyError(String error);

  String setlistReorderError(String error);

  String get rehearsalDetailTitle;

  String get rehearsalDetailDeleteTooltip;

  String get rehearsalDetailSetlistEmpty;

  String rehearsalDetailSetlistTitle(int count);

  String get rehearsalDetailCopyPreviousAction;

  String get rehearsalDetailAddSongAction;

  String get rehearsalDetailInfoTitle;

  String get rehearsalDetailStartLabel;

  String get rehearsalDetailEndLabel;

  String get rehearsalDetailLocationLabel;

  String get rehearsalDetailRoomTitle;

  String get rehearsalDetailBookRoomAction;

  String get rehearsalDetailNoRoomBooked;

  String get rehearsalDetailRoomConfirmed;

  String get rehearsalDetailNotesTitle;

  String get setlistTableHeaderTitle;

  String get setlistTableHeaderKey;

  String get setlistTableHeaderBpm;

  String get setlistTableHeaderNotes;

  String get setlistTableUntitledSong;

  String get setlistTableDeleteTooltip;

  String get setlistTableBpmUnit;

  String get setlistItemAddSongTitle;

  String get setlistItemAddAction;

  String get setlistItemSongLabel;

  String get setlistItemSongHint;

  String get setlistItemKeyLabel;

  String get setlistItemTempoLabel;

  String get setlistItemOrderLabel;

  String get setlistItemNotesLabel;

  String get setlistItemLinkLabel;

  String get setlistItemLinkHint;

  String get setlistItemSheetSelected;

  String get setlistItemUploadSheet;

  String get rehearsalDialogPickDateTime;

  String get rehearsalDialogOptional;

  String get rehearsalDialogNewTitle;

  String get rehearsalDialogStartLabel;

  String get rehearsalDialogEndLabel;

  String get rehearsalDialogRemoveEndTooltip;

  String get rehearsalDialogLocationLabel;

  String get rehearsalDialogLocationHint;

  String get rehearsalDialogNotesLabel;

  String get rehearsalDialogNotesHint;

  String get rehearsalDialogCreateAction;

  String get rehearsalDialogEndBeforeStartError;

  String get inviteDialogTitle;

  String get inviteSearchLabel;

  String get inviteSearchHint;

  String get inviteTypeAtLeastOneCharacter;

  String get inviteNoResults;

  String get inviteCreatedTitle;

  String inviteCreatedFor(String name);

  String get inviteCopyLinkAction;

  String get inviteLinkCopied;

  String inviteCreateError(String error);

  String get musicianContactTitle;

  String get musicianContactDescription;

  String get musicianContactLoading;

  String get musicianContactButton;

  String get musicianInviteButton;

  String eventsForDate(String dateLabel);

  String eventsPeopleCount(int count);

  String get rehearsalsGroupsMyGroupsTab;

  String get rehearsalsGroupsAgendaTab;

  String get rehearsalsGroupsErrorLoading;

  String get rehearsalsGroupsRetryButton;

  String rehearsalsGroupsCreateGroupError(String error);

  String get cancel;

  String get error;

  String get rehearsalsGroupsAgendaNoRehearsalsTitle;

  String get rehearsalsGroupsAgendaNoRehearsalsSubtitle;

  String get homeUpcomingEventsTitle;

  String get homeNextRehearsalLabel;

  String get homeNextRehearsalFallbackTitle;

  String get viewAll;

  String get homeRecommendedTitle;

  String get homeRecommendedSubtitle;

  String get homeNewTalentTitle;

  String get homeNewTalentSubtitle;

  String get homeExploreByInstrumentTitle;

  String get homeExploreByInstrumentSubtitle;

  String rehearsalsSidebarErrorLoading(String error);

  String get rehearsalsSidebarNewGroupLabel;

  String get rehearsalsSidebarEmptyPrompt;

  String rehearsalsSidebarRoleLabel(String role);

  String get rehearsalsSidebarCreateGroupTitle;

  String get rehearsalsSidebarGroupNameLabel;

  String get rehearsalsSidebarGroupNameHint;

  String get create;

  String get userSidebarTitle;

  String get searchAdvancedTitle;

  String get searchFiltersTitle;

  String searchFiltersWithCount(int count);

  String get searchTopBarHint;

  String get searchInstrumentLabel;

  String get searchInstrumentHint;

  String get searchStyleLabel;

  String get searchStyleHint;

  String get searchProfileTypeLabel;

  String get searchProfileTypeHint;

  String get searchProvinceLabel;

  String get searchProvinceHint;

  String get searchCityLabel;

  String get searchCityHint;

  String get searchCityUnavailable;

  String get searchClearFilters;

  String get searchAction;

  String get searchGenderLabel;

  String get searchGenderHint;

  String get searchUnassignedOption;

  String get searchAnyOption;

  String get searchFemaleOption;

  String get searchMaleOption;

  String get searchAdvancedFiltersTitle;

  String get searchAdvancedFiltersSubtitle;

  String get searchProvincesLoadHint;

  String get searchCitiesLoadHint;

  String get studios;

  String get studiosSubtitle;

  String get studiosDashboard;

  String get studiosManage;

  String get studiosRegister;

  String get studiosCreateTitle;

  String get studiosCreateSectionStudioData;

  String get studiosCreateSectionLocation;

  String get studiosCreateSectionFiscal;

  String get studiosCreateSectionAccessibility;

  String get studiosCreateAction;

  String get studiosCreateSuccess;

  String get studiosCreateAuthRequired;

  String get studiosCreateInsuranceDateRequired;

  String get studiosCreateMaxCapacityInvalid;

  String get studioProfileUpdateSuccess;

  String get studioProfileUpdateError;

  String get studioProfileImagesUpdateError;

  String get studioProfileNotFound;

  String get studioDashboardTabRooms;

  String get studioDashboardTabBookings;

  String get studioDashboardRoomsTitle;

  String get studioDashboardAddRoom;

  String get studioDashboardLoadMoreBookings;

  String studioDashboardBookingTotal(String total);

  String studioDashboardRoomSummary(String capacity, String price);

  String get studioSidebarManagementTitle;

  String get studioSidebarFallbackName;

  String get studioSidebarSessionLabel;

  String get studioSidebarMenuDashboard;

  String get studioSidebarMenuBookings;

  String get studioSidebarMenuRooms;

  String get studioSidebarMenuProfile;

  String get studioSidebarLogout;

  String get studioSidebarThemeLight;

  String get studioSidebarThemeDark;

  String get studioEmptyNoStudioTitle;

  String get studioEmptyNoStudioSubtitle;

  String get studioEmptyNoStudioAction;

  String get studioEmptyNoRoomsTitle;

  String get studioEmptyNoRoomsSubtitle;

  String get studioEmptyNoBookingsTitle;

  String get studioEmptyNoBookingsSubtitle;

  String get roomFormAddTitle;

  String get roomFormEditTitle;

  String get roomFormNameLabel;

  String get roomFormCapacityLabel;

  String get roomFormSizeLabel;

  String get roomFormPricePerHourLabel;

  String get roomFormEquipmentLabel;

  String get roomFormRequiredField;

  String get roomFormSectionConfig;

  String get roomFormMinBookingHoursLabel;

  String get roomFormMinBookingHoursHelp;

  String get roomFormMaxDecibelsLabel;

  String get roomFormMaxDecibelsHelp;

  String get roomFormAgeRestrictionLabel;

  String get roomFormAgeRestrictionHelp;

  String get roomFormSectionPolicies;

  String get roomFormCancellationPolicyLabel;

  String get roomFormCancellationPolicyHelp;

  String get roomFormAccessibleTitle;

  String get roomFormAccessibleSubtitle;

  String get roomFormActiveTitle;

  String get roomFormActiveSubtitle;

  String get roomFormCreateAction;

  String get roomFormSaveError;

  String get roomFormPhotosTitle;

  String get roomFormAttachPhotos;

  String get studiosListTitleForRehearsal;

  String get studiosListEmpty;

  String get studiosListLoadMore;

  String get studioRoomsTitle;

  String get studioRoomsEmpty;

  String get musicianBookingsLoginRequired;

  String get musicianBookingsLoadError;

  String get musicianBookingsRetry;

  String get musicianBookingsEmpty;

  String get musicianBookingsTitle;

  String get musicianBookingsUpcoming;

  String get musicianBookingsHistory;

  String get musicianBookingsLoadMore;

  String get bookingStatusConfirmed;

  String get bookingStatusCancelled;

  String get bookingStatusRefunded;

  String get bookingStatusPending;

  String roomCardPricePerHour(String price);

  String roomCardCapacity(int count);

  String get studioCardViewRooms;

  String get eventsNewEventButton;

  String get eventsViewDetails;

  String get eventsViewTextSheet;

  String get eventsCopyFormat;

  String get eventsCopySheetTooltip;

  String get onboardingInfluencesTitle;

  String get onboardingInfluencesDescription;

  String get onboardingInfluencesEmpty;

  String get affinityStyleLabel;

  String get affinityArtistBandLabel;

  String get affinitySuggestedOptionsLabel;

  String get affinityNoMatchesForStyle;

  String get affinityAddButton;

  String get affinityAddTooltip;

  String get profileAffinityTitle;

  String get profileAffinityDescription;

  String get profileAffinityEmpty;

  String roomDetailPricePerHour(String price);

  String roomDetailCapacity(int count);

  String roomDetailSize(String size);

  String get roomDetailEquipmentTitle;

  String get roomDetailBookForRehearsal;

  String get roomDetailBookRoom;

  String roomDetailBookingSuccessForRehearsal(String total);

  String roomDetailBookingSuccess(String total);

  String get roomDetailBookingError;

  String get roomDetailPrefilledFromRehearsal;

  String get roomDetailDateLabel;

  String get roomDetailSelectDate;

  String get roomDetailStartTimeLabel;

  String get roomDetailSelectTime;

  String roomDetailDurationHours(int hours);

  String roomDetailMinBookingHours(int hours);

  String roomDetailMaxDecibels(String decibels);

  String roomDetailMinimumAge(int age);

  String get roomDetailAccessibleMobility;

  String get roomDetailCancellationPolicyTitle;

  String get roomDetailPaymentMethodLabel;

  String get roomDetailVatLabel;

  String get paymentMethodCard;

  String get paymentMethodTransfer;

  String get paymentMethodCash;

  String get paymentMethodBizum;

  String get roomDetailTotalPriceLabel;

  String get roomDetailConfirmBookingForRehearsal;

  String get roomDetailConfirmBooking;

  String get homeExploreLabel;

  String get homeGreetingSubtitle;

  String get venueShellBrandName;

  String get venueMenuDashboard;

  String get venueMenuNewVenue;

  String get venueMenuExploreVenues;

  String get venueMenuLogout;

  String get venueBottomNavPanel;

  String get venueBottomNavExplore;

  String get venuePublicListTitle;

  String get venueFiltersApply;

  String get venueFieldCity;

  String get venueFieldProvince;

  String get venueLoadMore;

  String get venueRetry;

  String get venuePublicEmpty;

  String get venueManagerEmpty;

  String get venueManagerDeactivateTitle;

  String venueManagerDeactivateMessage(String venueName);

  String get venueManagerDeactivateAction;

  String get venueManagerNewVenue;

  String get venueManagerHeadingTitle;

  String venueCardCapacityLabel(int capacity);

  String get venueCardPublic;

  String get venueCardPrivate;

  String get venueCardSourceStudioSync;

  String get venueCardSourceNative;

  String get venueCardEdit;

  String get venueCardDeactivate;

  String get venueLoginTitle;

  String get venueLoginSubtitle;

  String get venueLoginRegisterPrompt;

  String get venueRegisterTitle;

  String get venueRegisterSubtitle;

  String get venueRegisterVenueNameLabel;

  String get venueRegisterVenueNameHint;

  String get venueRegisterEmailLabel;

  String get venueRegisterEmailHint;

  String get venueRegisterPasswordLabel;

  String get venueRegisterPasswordHint;

  String get venueRegisterPhoneLabel;

  String get venueRegisterPhoneHint;

  String get venueRegisterCityHint;

  String get venueRegisterWebsiteLabel;

  String get venueRegisterWebsiteHint;

  String get venueRegisterSubmitting;

  String get venueRegisterCreateAccount;

  String get venueRegisterLoginPrompt;

  String get venueFormSavedSuccess;

  String get venueFormEditTitle;

  String get venueFormNewTitle;

  String get venueFormSaving;

  String get venueFormSave;

  String get venueFormSectionBasics;

  String get venueFormSectionLocation;

  String get venueFormSectionContact;

  String get venueFormSectionCompliance;

  String get venueFormFieldVenueName;

  String get venueFormFieldDescription;

  String get venueFormFieldAddress;

  String get venueFormFieldPostalCodeOptional;

  String get venueFormFieldContactEmail;

  String get venueFormFieldContactPhone;

  String get venueFormFieldLicenseNumber;

  String get venueFormFieldMaxCapacity;

  String get venueFormFieldAccessibility;

  String get venueFormVisibleToMusicians;

  String get venueFormVisibleToMusiciansHint;

  String get venueValidationRequired;

  String get venueValidationEmailInvalid;

  String get venueValidationPositiveInt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
