import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'UPSESSIONS'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a la comunidad musical.'**
  String get welcome;

  /// No description provided for @searchMusicians.
  ///
  /// In es, this message translates to:
  /// **'Busca músicos y bandas por todo el país.'**
  String get searchMusicians;

  /// No description provided for @announcements.
  ///
  /// In es, this message translates to:
  /// **'Anuncios recientes'**
  String get announcements;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil musical'**
  String get profile;

  /// No description provided for @appBrandName.
  ///
  /// In es, this message translates to:
  /// **'UPSESSIONS'**
  String get appBrandName;

  /// No description provided for @appWelcomeTagline.
  ///
  /// In es, this message translates to:
  /// **'Conecta tu música\nsin limite.'**
  String get appWelcomeTagline;

  /// No description provided for @startButton.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get startButton;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @registerPageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Únete a la red de Solo Músicos'**
  String get registerPageSubtitle;

  /// No description provided for @registerPageLoginPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? Inicia sesión'**
  String get registerPageLoginPrompt;

  /// No description provided for @loginContinueWith.
  ///
  /// In es, this message translates to:
  /// **'O continúa con'**
  String get loginContinueWith;

  /// No description provided for @continueWithProvider.
  ///
  /// In es, this message translates to:
  /// **'Continuar con {provider}'**
  String continueWithProvider(String provider);

  /// No description provided for @socialLoginPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'El inicio de sesión con {provider} estará disponible pronto.'**
  String socialLoginPlaceholder(String provider);

  /// No description provided for @providerEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get providerEmail;

  /// No description provided for @providerGoogle.
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get providerGoogle;

  /// No description provided for @providerFacebook.
  ///
  /// In es, this message translates to:
  /// **'Facebook'**
  String get providerFacebook;

  /// No description provided for @providerApple.
  ///
  /// In es, this message translates to:
  /// **'Apple'**
  String get providerApple;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get emailInvalid;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordHint;

  /// No description provided for @passwordToggleShow.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get passwordToggleShow;

  /// No description provided for @passwordToggleHide.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get passwordToggleHide;

  /// No description provided for @passwordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 4 caracteres'**
  String get passwordTooShort;

  /// No description provided for @onboardingCollaborateTitle.
  ///
  /// In es, this message translates to:
  /// **'Conecta con músicos reales'**
  String get onboardingCollaborateTitle;

  /// No description provided for @onboardingCollaborateDescription.
  ///
  /// In es, this message translates to:
  /// **'Descubre instrumentistas y productores disponibles para sesiones en vivo o remotas.'**
  String get onboardingCollaborateDescription;

  /// No description provided for @onboardingShowcaseTitle.
  ///
  /// In es, this message translates to:
  /// **'Muestra tu talento'**
  String get onboardingShowcaseTitle;

  /// No description provided for @onboardingShowcaseDescription.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu música'**
  String get onboardingShowcaseDescription;

  /// No description provided for @onboardingBookTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu centro de reservas musical'**
  String get onboardingBookTitle;

  /// No description provided for @onboardingBookDescription.
  ///
  /// In es, this message translates to:
  /// **'Coordina disponibilidad, contratos y pagos en pocos clicks.'**
  String get onboardingBookDescription;

  /// No description provided for @eventsShowcasesTitle.
  ///
  /// In es, this message translates to:
  /// **'Eventos y showcases'**
  String get eventsShowcasesTitle;

  /// No description provided for @eventsShowcasesDescription.
  ///
  /// In es, this message translates to:
  /// **'Planifica tus sesiones. Genera una ficha en formato texto para compartirla por correo o chat.'**
  String get eventsShowcasesDescription;

  /// No description provided for @eventsActiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Eventos activos'**
  String get eventsActiveLabel;

  /// No description provided for @eventsThisWeekLabel.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get eventsThisWeekLabel;

  /// No description provided for @eventsTotalCapacityLabel.
  ///
  /// In es, this message translates to:
  /// **'Capacidad total'**
  String get eventsTotalCapacityLabel;

  /// No description provided for @eventsEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay eventos publicados. Sé el primero en crear uno desde la sección Eventos.'**
  String get eventsEmptyMessage;

  /// No description provided for @noEventsOnDate.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos registrados en esta fecha.'**
  String get noEventsOnDate;

  /// No description provided for @navMusicians.
  ///
  /// In es, this message translates to:
  /// **'Músicos'**
  String get navMusicians;

  /// No description provided for @navAnnouncements.
  ///
  /// In es, this message translates to:
  /// **'Anuncios'**
  String get navAnnouncements;

  /// No description provided for @navEvents.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get navEvents;

  /// No description provided for @navRehearsals.
  ///
  /// In es, this message translates to:
  /// **'Ensayos'**
  String get navRehearsals;

  /// No description provided for @rehearsalsPageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiona los ensayos de tu grupo'**
  String get rehearsalsPageSubtitle;

  /// No description provided for @rehearsalsSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get rehearsalsSummaryTitle;

  /// No description provided for @rehearsalsTotalCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 ensayo programado} other{# ensayos programados}}'**
  String rehearsalsTotalCount(int count);

  /// No description provided for @rehearsalsNextLabel.
  ///
  /// In es, this message translates to:
  /// **'Próximo'**
  String get rehearsalsNextLabel;

  /// No description provided for @rehearsalsTotalStat.
  ///
  /// In es, this message translates to:
  /// **'Total Ensayos'**
  String get rehearsalsTotalStat;

  /// No description provided for @rehearsalsNoUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Sin programar'**
  String get rehearsalsNoUpcoming;

  /// No description provided for @rehearsalsNewButton.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Ensayo'**
  String get rehearsalsNewButton;

  /// No description provided for @rehearsalsAddMusicianButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar Músico'**
  String get rehearsalsAddMusicianButton;

  /// No description provided for @rehearsalsOnlyAdmin.
  ///
  /// In es, this message translates to:
  /// **'Solo Admin'**
  String get rehearsalsOnlyAdmin;

  /// No description provided for @rehearsalsFilterUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximos'**
  String get rehearsalsFilterUpcoming;

  /// No description provided for @rehearsalsFilterPast.
  ///
  /// In es, this message translates to:
  /// **'Pasados'**
  String get rehearsalsFilterPast;

  /// No description provided for @rehearsalsFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get rehearsalsFilterAll;

  /// No description provided for @musicianContactTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Te interesa colaborar?'**
  String get musicianContactTitle;

  /// No description provided for @musicianContactDescription.
  ///
  /// In es, this message translates to:
  /// **'Conecta por chat para coordinar detalles y disponibilidad.'**
  String get musicianContactDescription;

  /// No description provided for @musicianContactLoading.
  ///
  /// In es, this message translates to:
  /// **'Abriendo...'**
  String get musicianContactLoading;

  /// No description provided for @musicianContactButton.
  ///
  /// In es, this message translates to:
  /// **'Contactar'**
  String get musicianContactButton;

  /// No description provided for @musicianInviteButton.
  ///
  /// In es, this message translates to:
  /// **'Invitar'**
  String get musicianInviteButton;

  /// No description provided for @eventsForDate.
  ///
  /// In es, this message translates to:
  /// **'Eventos para {dateLabel}'**
  String eventsForDate(String dateLabel);

  /// No description provided for @eventsPeopleCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{# persona} other{# personas}}'**
  String eventsPeopleCount(int count);

  /// No description provided for @rehearsalsGroupsMyGroupsTab.
  ///
  /// In es, this message translates to:
  /// **'Mis Grupos'**
  String get rehearsalsGroupsMyGroupsTab;

  /// No description provided for @rehearsalsGroupsAgendaTab.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get rehearsalsGroupsAgendaTab;

  /// No description provided for @rehearsalsGroupsErrorLoading.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus grupos.'**
  String get rehearsalsGroupsErrorLoading;

  /// No description provided for @rehearsalsGroupsRetryButton.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get rehearsalsGroupsRetryButton;

  /// No description provided for @rehearsalsGroupsCreateGroupError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el grupo: {error}'**
  String rehearsalsGroupsCreateGroupError(String error);

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @rehearsalsGroupsAgendaNoRehearsalsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay ensayos'**
  String get rehearsalsGroupsAgendaNoRehearsalsTitle;

  /// No description provided for @rehearsalsGroupsAgendaNoRehearsalsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás tus próximos ensayos de todos tus grupos.'**
  String get rehearsalsGroupsAgendaNoRehearsalsSubtitle;

  /// No description provided for @homeUpcomingEventsTitle.
  ///
  /// In es, this message translates to:
  /// **'Próximos eventos'**
  String get homeUpcomingEventsTitle;

  /// No description provided for @homeNextRehearsalLabel.
  ///
  /// In es, this message translates to:
  /// **'Próximo ensayo'**
  String get homeNextRehearsalLabel;

  /// No description provided for @homeNextRehearsalFallbackTitle.
  ///
  /// In es, this message translates to:
  /// **'Ensayo programado'**
  String get homeNextRehearsalFallbackTitle;

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get viewAll;

  /// No description provided for @homeRecommendedTitle.
  ///
  /// In es, this message translates to:
  /// **'Recomendados para ti'**
  String get homeRecommendedTitle;

  /// No description provided for @homeRecommendedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Basado en tus estilos favoritos'**
  String get homeRecommendedSubtitle;

  /// No description provided for @homeNewTalentTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevos talentos'**
  String get homeNewTalentTitle;

  /// No description provided for @homeNewTalentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Músicos recién llegados a la comunidad'**
  String get homeNewTalentSubtitle;

  /// No description provided for @homeExploreByInstrumentTitle.
  ///
  /// In es, this message translates to:
  /// **'Explora por instrumento'**
  String get homeExploreByInstrumentTitle;

  /// No description provided for @homeExploreByInstrumentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Filtra por instrumento para encontrar a tu próximo colaborador.'**
  String get homeExploreByInstrumentSubtitle;

  /// No description provided for @rehearsalsSidebarErrorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error cargando grupos: {error}'**
  String rehearsalsSidebarErrorLoading(String error);

  /// No description provided for @rehearsalsSidebarNewGroupLabel.
  ///
  /// In es, this message translates to:
  /// **'Nuevo grupo'**
  String get rehearsalsSidebarNewGroupLabel;

  /// No description provided for @rehearsalsSidebarEmptyPrompt.
  ///
  /// In es, this message translates to:
  /// **'Crea un grupo para empezar.'**
  String get rehearsalsSidebarEmptyPrompt;

  /// No description provided for @rehearsalsSidebarRoleLabel.
  ///
  /// In es, this message translates to:
  /// **'Rol: {role}'**
  String rehearsalsSidebarRoleLabel(String role);

  /// No description provided for @rehearsalsSidebarCreateGroupTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear grupo'**
  String get rehearsalsSidebarCreateGroupTitle;

  /// No description provided for @rehearsalsSidebarGroupNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get rehearsalsSidebarGroupNameLabel;

  /// No description provided for @rehearsalsSidebarGroupNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Banda X'**
  String get rehearsalsSidebarGroupNameHint;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @userSidebarTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu panel'**
  String get userSidebarTitle;

  /// No description provided for @searchAdvancedTitle.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda avanzada'**
  String get searchAdvancedTitle;

  /// No description provided for @searchFiltersTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get searchFiltersTitle;

  /// No description provided for @searchFiltersWithCount.
  ///
  /// In es, this message translates to:
  /// **'Filtros ({count})'**
  String searchFiltersWithCount(int count);

  /// No description provided for @searchTopBarHint.
  ///
  /// In es, this message translates to:
  /// **'Busca por nombre, estilo o instrumento'**
  String get searchTopBarHint;

  /// No description provided for @searchInstrumentLabel.
  ///
  /// In es, this message translates to:
  /// **'Instrumento'**
  String get searchInstrumentLabel;

  /// No description provided for @searchInstrumentHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona instrumento'**
  String get searchInstrumentHint;

  /// No description provided for @searchStyleLabel.
  ///
  /// In es, this message translates to:
  /// **'Estilo'**
  String get searchStyleLabel;

  /// No description provided for @searchStyleHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona estilo'**
  String get searchStyleHint;

  /// No description provided for @searchProfileTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de perfil'**
  String get searchProfileTypeLabel;

  /// No description provided for @searchProfileTypeHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tipo'**
  String get searchProfileTypeHint;

  /// No description provided for @searchProvinceLabel.
  ///
  /// In es, this message translates to:
  /// **'Provincia'**
  String get searchProvinceLabel;

  /// No description provided for @searchProvinceHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona provincia'**
  String get searchProvinceHint;

  /// No description provided for @searchCityLabel.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get searchCityLabel;

  /// No description provided for @searchCityHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona ciudad'**
  String get searchCityHint;

  /// No description provided for @searchCityUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Sin ciudades disponibles'**
  String get searchCityUnavailable;

  /// No description provided for @searchClearFilters.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtros'**
  String get searchClearFilters;

  /// No description provided for @searchAction.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get searchAction;

  /// No description provided for @searchGenderLabel.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get searchGenderLabel;

  /// No description provided for @searchGenderHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona género'**
  String get searchGenderHint;

  /// No description provided for @searchUnassignedOption.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get searchUnassignedOption;

  /// No description provided for @searchAnyOption.
  ///
  /// In es, this message translates to:
  /// **'Cualquiera'**
  String get searchAnyOption;

  /// No description provided for @searchFemaleOption.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get searchFemaleOption;

  /// No description provided for @searchMaleOption.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get searchMaleOption;

  /// No description provided for @searchAdvancedFiltersTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros avanzados'**
  String get searchAdvancedFiltersTitle;

  /// No description provided for @searchAdvancedFiltersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Toca para ajustar los filtros'**
  String get searchAdvancedFiltersSubtitle;

  /// No description provided for @searchProvincesLoadHint.
  ///
  /// In es, this message translates to:
  /// **'Carga provincias españolas desde Firestore (metadata/geography.provinces).'**
  String get searchProvincesLoadHint;

  /// No description provided for @searchCitiesLoadHint.
  ///
  /// In es, this message translates to:
  /// **'Añade ciudades por provincia en Firestore (metadata/geography.citiesByProvince).'**
  String get searchCitiesLoadHint;

  /// No description provided for @studios.
  ///
  /// In es, this message translates to:
  /// **'Salas de Ensayo'**
  String get studios;

  /// No description provided for @studiosSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reserva el espacio ideal para tu banda'**
  String get studiosSubtitle;

  /// No description provided for @studiosDashboard.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Sala'**
  String get studiosDashboard;

  /// No description provided for @studiosManage.
  ///
  /// In es, this message translates to:
  /// **'Gestionar Sala'**
  String get studiosManage;

  /// No description provided for @studiosRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrar Sala'**
  String get studiosRegister;
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
  // Lookup logic when only language code is specified.
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
