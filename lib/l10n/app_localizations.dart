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

  /// No description provided for @eventsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos'**
  String get eventsEmptyTitle;

  /// No description provided for @eventsEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay eventos publicados. Sé el primero en crear uno desde la sección Eventos.'**
  String get eventsEmptyMessage;

  /// No description provided for @announcementsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay anuncios'**
  String get announcementsEmptyTitle;

  /// No description provided for @announcementsEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Publica el primero o vuelve más tarde.'**
  String get announcementsEmptySubtitle;

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

  /// No description provided for @rehearsalsErrorWithMessage.
  ///
  /// In es, this message translates to:
  /// **'Error: {message}'**
  String rehearsalsErrorWithMessage(String message);

  /// No description provided for @rehearsalsGroupFallbackName.
  ///
  /// In es, this message translates to:
  /// **'Grupo'**
  String get rehearsalsGroupFallbackName;

  /// No description provided for @rehearsalsCreateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el ensayo: {error}'**
  String rehearsalsCreateError(String error);

  /// No description provided for @rehearsalsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ensayos'**
  String get rehearsalsEmptyTitle;

  /// No description provided for @rehearsalsEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea el primero para empezar a armar el setlist.'**
  String get rehearsalsEmptySubtitle;

  /// No description provided for @rehearsalsFilterEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get rehearsalsFilterEmptyTitle;

  /// No description provided for @rehearsalsFilterEmptyUpcoming.
  ///
  /// In es, this message translates to:
  /// **'No hay ensayos próximos.'**
  String get rehearsalsFilterEmptyUpcoming;

  /// No description provided for @rehearsalsFilterEmptyPast.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ensayos pasados.'**
  String get rehearsalsFilterEmptyPast;

  /// No description provided for @rehearsalsFilterEmptyAll.
  ///
  /// In es, this message translates to:
  /// **'No hay ensayos para mostrar.'**
  String get rehearsalsFilterEmptyAll;

  /// No description provided for @deleteAction.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get deleteAction;

  /// No description provided for @saveAction.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get saveAction;

  /// No description provided for @closeAction.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get closeAction;

  /// No description provided for @doneAction.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get doneAction;

  /// No description provided for @removeAction.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get removeAction;

  /// No description provided for @rehearsalsDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar ensayo'**
  String get rehearsalsDeleteTitle;

  /// No description provided for @rehearsalsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará el ensayo y su setlist. ¿Continuar?'**
  String get rehearsalsDeleteMessage;

  /// No description provided for @rehearsalsDeleteSuccess.
  ///
  /// In es, this message translates to:
  /// **'Ensayo eliminado.'**
  String get rehearsalsDeleteSuccess;

  /// No description provided for @rehearsalsDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar el ensayo: {error}'**
  String rehearsalsDeleteError(String error);

  /// No description provided for @rehearsalsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar ensayo'**
  String get rehearsalsEditTitle;

  /// No description provided for @rehearsalsUpdateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Ensayo actualizado.'**
  String get rehearsalsUpdateSuccess;

  /// No description provided for @rehearsalsUpdateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el ensayo: {error}'**
  String rehearsalsUpdateError(String error);

  /// No description provided for @setlistAddError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo agregar: {error}'**
  String setlistAddError(String error);

  /// No description provided for @setlistEditSongTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar canción'**
  String get setlistEditSongTitle;

  /// No description provided for @setlistUpdateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar: {error}'**
  String setlistUpdateError(String error);

  /// No description provided for @setlistDeleteItemTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar item'**
  String get setlistDeleteItemTitle;

  /// No description provided for @setlistDeleteItemMessage.
  ///
  /// In es, this message translates to:
  /// **'Eliminar \"{itemTitle}\" del setlist?'**
  String setlistDeleteItemMessage(String itemTitle);

  /// No description provided for @setlistDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar: {error}'**
  String setlistDeleteError(String error);

  /// No description provided for @setlistCopyNoPrevious.
  ///
  /// In es, this message translates to:
  /// **'No hay ensayos previos para copiar.'**
  String get setlistCopyNoPrevious;

  /// No description provided for @setlistCopyDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Copiar setlist'**
  String get setlistCopyDialogTitle;

  /// No description provided for @setlistCopyDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'Copiar el setlist del ensayo {dateLabel} a este ensayo?'**
  String setlistCopyDialogMessage(String dateLabel);

  /// No description provided for @setlistCopyAppendAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar al final'**
  String get setlistCopyAppendAction;

  /// No description provided for @setlistCopyReplaceAction.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar'**
  String get setlistCopyReplaceAction;

  /// No description provided for @setlistCopySuccess.
  ///
  /// In es, this message translates to:
  /// **'Setlist copiado.'**
  String get setlistCopySuccess;

  /// No description provided for @setlistCopyError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo copiar el setlist: {error}'**
  String setlistCopyError(String error);

  /// No description provided for @setlistReorderError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reordenar el setlist: {error}'**
  String setlistReorderError(String error);

  /// No description provided for @rehearsalDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Ensayo'**
  String get rehearsalDetailTitle;

  /// No description provided for @rehearsalDetailDeleteTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar ensayo'**
  String get rehearsalDetailDeleteTooltip;

  /// No description provided for @rehearsalDetailSetlistEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay canciones en el setlist'**
  String get rehearsalDetailSetlistEmpty;

  /// No description provided for @rehearsalDetailSetlistTitle.
  ///
  /// In es, this message translates to:
  /// **'Setlist ({count})'**
  String rehearsalDetailSetlistTitle(int count);

  /// No description provided for @rehearsalDetailCopyPreviousAction.
  ///
  /// In es, this message translates to:
  /// **'Copiar del anterior'**
  String get rehearsalDetailCopyPreviousAction;

  /// No description provided for @rehearsalDetailAddSongAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar canción'**
  String get rehearsalDetailAddSongAction;

  /// No description provided for @rehearsalDetailInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get rehearsalDetailInfoTitle;

  /// No description provided for @rehearsalDetailStartLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get rehearsalDetailStartLabel;

  /// No description provided for @rehearsalDetailEndLabel.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get rehearsalDetailEndLabel;

  /// No description provided for @rehearsalDetailLocationLabel.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get rehearsalDetailLocationLabel;

  /// No description provided for @rehearsalDetailRoomTitle.
  ///
  /// In es, this message translates to:
  /// **'Sala de Ensayo'**
  String get rehearsalDetailRoomTitle;

  /// No description provided for @rehearsalDetailBookRoomAction.
  ///
  /// In es, this message translates to:
  /// **'Reservar'**
  String get rehearsalDetailBookRoomAction;

  /// No description provided for @rehearsalDetailNoRoomBooked.
  ///
  /// In es, this message translates to:
  /// **'No hay sala reservada'**
  String get rehearsalDetailNoRoomBooked;

  /// No description provided for @rehearsalDetailRoomConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get rehearsalDetailRoomConfirmed;

  /// No description provided for @rehearsalDetailNotesTitle.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get rehearsalDetailNotesTitle;

  /// No description provided for @setlistTableHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get setlistTableHeaderTitle;

  /// No description provided for @setlistTableHeaderKey.
  ///
  /// In es, this message translates to:
  /// **'Tonalidad'**
  String get setlistTableHeaderKey;

  /// No description provided for @setlistTableHeaderBpm.
  ///
  /// In es, this message translates to:
  /// **'BPM'**
  String get setlistTableHeaderBpm;

  /// No description provided for @setlistTableHeaderNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get setlistTableHeaderNotes;

  /// No description provided for @setlistTableUntitledSong.
  ///
  /// In es, this message translates to:
  /// **'Sin título'**
  String get setlistTableUntitledSong;

  /// No description provided for @setlistTableDeleteTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar del setlist'**
  String get setlistTableDeleteTooltip;

  /// No description provided for @setlistTableBpmUnit.
  ///
  /// In es, this message translates to:
  /// **'BPM'**
  String get setlistTableBpmUnit;

  /// No description provided for @setlistItemAddSongTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar canción'**
  String get setlistItemAddSongTitle;

  /// No description provided for @setlistItemAddAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get setlistItemAddAction;

  /// No description provided for @setlistItemSongLabel.
  ///
  /// In es, this message translates to:
  /// **'Canción'**
  String get setlistItemSongLabel;

  /// No description provided for @setlistItemSongHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Autumn Leaves'**
  String get setlistItemSongHint;

  /// No description provided for @setlistItemKeyLabel.
  ///
  /// In es, this message translates to:
  /// **'Tono'**
  String get setlistItemKeyLabel;

  /// No description provided for @setlistItemTempoLabel.
  ///
  /// In es, this message translates to:
  /// **'Tempo (bpm)'**
  String get setlistItemTempoLabel;

  /// No description provided for @setlistItemOrderLabel.
  ///
  /// In es, this message translates to:
  /// **'Orden'**
  String get setlistItemOrderLabel;

  /// No description provided for @setlistItemNotesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get setlistItemNotesLabel;

  /// No description provided for @setlistItemLinkLabel.
  ///
  /// In es, this message translates to:
  /// **'Enlace (YouTube, etc.)'**
  String get setlistItemLinkLabel;

  /// No description provided for @setlistItemLinkHint.
  ///
  /// In es, this message translates to:
  /// **'https://…'**
  String get setlistItemLinkHint;

  /// No description provided for @setlistItemSheetSelected.
  ///
  /// In es, this message translates to:
  /// **'Partitura seleccionada'**
  String get setlistItemSheetSelected;

  /// No description provided for @setlistItemUploadSheet.
  ///
  /// In es, this message translates to:
  /// **'Subir partitura'**
  String get setlistItemUploadSheet;

  /// No description provided for @rehearsalDialogPickDateTime.
  ///
  /// In es, this message translates to:
  /// **'Elegir fecha/hora'**
  String get rehearsalDialogPickDateTime;

  /// No description provided for @rehearsalDialogOptional.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get rehearsalDialogOptional;

  /// No description provided for @rehearsalDialogNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo ensayo'**
  String get rehearsalDialogNewTitle;

  /// No description provided for @rehearsalDialogStartLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get rehearsalDialogStartLabel;

  /// No description provided for @rehearsalDialogEndLabel.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get rehearsalDialogEndLabel;

  /// No description provided for @rehearsalDialogRemoveEndTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar fin'**
  String get rehearsalDialogRemoveEndTooltip;

  /// No description provided for @rehearsalDialogLocationLabel.
  ///
  /// In es, this message translates to:
  /// **'Lugar'**
  String get rehearsalDialogLocationLabel;

  /// No description provided for @rehearsalDialogLocationHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Sala 2 / Estudio'**
  String get rehearsalDialogLocationHint;

  /// No description provided for @rehearsalDialogNotesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get rehearsalDialogNotesLabel;

  /// No description provided for @rehearsalDialogNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Traer metrónomo'**
  String get rehearsalDialogNotesHint;

  /// No description provided for @rehearsalDialogCreateAction.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get rehearsalDialogCreateAction;

  /// No description provided for @rehearsalDialogEndBeforeStartError.
  ///
  /// In es, this message translates to:
  /// **'El fin no puede ser antes del inicio.'**
  String get rehearsalDialogEndBeforeStartError;

  /// No description provided for @inviteDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar músico'**
  String get inviteDialogTitle;

  /// No description provided for @inviteSearchLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre'**
  String get inviteSearchLabel;

  /// No description provided for @inviteSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. ana'**
  String get inviteSearchHint;

  /// No description provided for @inviteTypeAtLeastOneCharacter.
  ///
  /// In es, this message translates to:
  /// **'Escribe al menos 1 carácter.'**
  String get inviteTypeAtLeastOneCharacter;

  /// No description provided for @inviteNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados.'**
  String get inviteNoResults;

  /// No description provided for @inviteCreatedTitle.
  ///
  /// In es, this message translates to:
  /// **'Invitación creada'**
  String get inviteCreatedTitle;

  /// No description provided for @inviteCreatedFor.
  ///
  /// In es, this message translates to:
  /// **'Para: {name}'**
  String inviteCreatedFor(String name);

  /// No description provided for @inviteCopyLinkAction.
  ///
  /// In es, this message translates to:
  /// **'Copiar link'**
  String get inviteCopyLinkAction;

  /// No description provided for @inviteLinkCopied.
  ///
  /// In es, this message translates to:
  /// **'Link copiado.'**
  String get inviteLinkCopied;

  /// No description provided for @inviteCreateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear la invitación: {error}'**
  String inviteCreateError(String error);

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

  /// No description provided for @studiosCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar estudio'**
  String get studiosCreateTitle;

  /// No description provided for @studiosCreateSectionStudioData.
  ///
  /// In es, this message translates to:
  /// **'Datos del estudio'**
  String get studiosCreateSectionStudioData;

  /// No description provided for @studiosCreateSectionLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get studiosCreateSectionLocation;

  /// No description provided for @studiosCreateSectionFiscal.
  ///
  /// In es, this message translates to:
  /// **'Normativa fiscal y administrativa'**
  String get studiosCreateSectionFiscal;

  /// No description provided for @studiosCreateSectionAccessibility.
  ///
  /// In es, this message translates to:
  /// **'Accesibilidad y seguro'**
  String get studiosCreateSectionAccessibility;

  /// No description provided for @studiosCreateAction.
  ///
  /// In es, this message translates to:
  /// **'Crear estudio'**
  String get studiosCreateAction;

  /// No description provided for @studiosCreateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Estudio creado correctamente.'**
  String get studiosCreateSuccess;

  /// No description provided for @studiosCreateAuthRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para crear un estudio.'**
  String get studiosCreateAuthRequired;

  /// No description provided for @studiosCreateInsuranceDateRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha de caducidad del seguro RC.'**
  String get studiosCreateInsuranceDateRequired;

  /// No description provided for @studiosCreateMaxCapacityInvalid.
  ///
  /// In es, this message translates to:
  /// **'Aforo máximo inválido (debe ser > 0).'**
  String get studiosCreateMaxCapacityInvalid;

  /// No description provided for @studioProfileUpdateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado correctamente.'**
  String get studioProfileUpdateSuccess;

  /// No description provided for @studioProfileUpdateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los cambios.'**
  String get studioProfileUpdateError;

  /// No description provided for @studioProfileImagesUpdateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron actualizar las imágenes.'**
  String get studioProfileImagesUpdateError;

  /// No description provided for @studioProfileNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el estudio.'**
  String get studioProfileNotFound;

  /// No description provided for @studioDashboardTabRooms.
  ///
  /// In es, this message translates to:
  /// **'Mis salas'**
  String get studioDashboardTabRooms;

  /// No description provided for @studioDashboardTabBookings.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get studioDashboardTabBookings;

  /// No description provided for @studioDashboardRoomsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis salas'**
  String get studioDashboardRoomsTitle;

  /// No description provided for @studioDashboardAddRoom.
  ///
  /// In es, this message translates to:
  /// **'Añadir sala'**
  String get studioDashboardAddRoom;

  /// No description provided for @studioDashboardLoadMoreBookings.
  ///
  /// In es, this message translates to:
  /// **'Cargar más reservas'**
  String get studioDashboardLoadMoreBookings;

  /// No description provided for @studioDashboardBookingTotal.
  ///
  /// In es, this message translates to:
  /// **'Total: {total}€'**
  String studioDashboardBookingTotal(String total);

  /// No description provided for @studioDashboardRoomSummary.
  ///
  /// In es, this message translates to:
  /// **'{capacity} personas • {price}€/hora'**
  String studioDashboardRoomSummary(String capacity, String price);

  /// No description provided for @studioSidebarManagementTitle.
  ///
  /// In es, this message translates to:
  /// **'GESTIÓN DE ESTUDIO'**
  String get studioSidebarManagementTitle;

  /// No description provided for @studioSidebarFallbackName.
  ///
  /// In es, this message translates to:
  /// **'Mi estudio'**
  String get studioSidebarFallbackName;

  /// No description provided for @studioSidebarSessionLabel.
  ///
  /// In es, this message translates to:
  /// **'Sesión de estudio'**
  String get studioSidebarSessionLabel;

  /// No description provided for @studioSidebarMenuDashboard.
  ///
  /// In es, this message translates to:
  /// **'Panel'**
  String get studioSidebarMenuDashboard;

  /// No description provided for @studioSidebarMenuBookings.
  ///
  /// In es, this message translates to:
  /// **'Mis reservas'**
  String get studioSidebarMenuBookings;

  /// No description provided for @studioSidebarMenuRooms.
  ///
  /// In es, this message translates to:
  /// **'Mis salas'**
  String get studioSidebarMenuRooms;

  /// No description provided for @studioSidebarMenuProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil del estudio'**
  String get studioSidebarMenuProfile;

  /// No description provided for @studioSidebarLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get studioSidebarLogout;

  /// No description provided for @studioSidebarThemeLight.
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get studioSidebarThemeLight;

  /// No description provided for @studioSidebarThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get studioSidebarThemeDark;

  /// No description provided for @studioEmptyNoStudioTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado tu estudio'**
  String get studioEmptyNoStudioTitle;

  /// No description provided for @studioEmptyNoStudioSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu perfil de estudio para empezar a recibir reservas'**
  String get studioEmptyNoStudioSubtitle;

  /// No description provided for @studioEmptyNoStudioAction.
  ///
  /// In es, this message translates to:
  /// **'Registrar estudio'**
  String get studioEmptyNoStudioAction;

  /// No description provided for @studioEmptyNoRoomsTitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes salas registradas'**
  String get studioEmptyNoRoomsTitle;

  /// No description provided for @studioEmptyNoRoomsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Añade tu primera sala para comenzar a recibir reservas'**
  String get studioEmptyNoRoomsSubtitle;

  /// No description provided for @studioEmptyNoBookingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin reservas pendientes'**
  String get studioEmptyNoBookingsTitle;

  /// No description provided for @studioEmptyNoBookingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cuando recibas reservas aparecerán aquí'**
  String get studioEmptyNoBookingsSubtitle;

  /// No description provided for @roomFormAddTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir sala'**
  String get roomFormAddTitle;

  /// No description provided for @roomFormEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar sala'**
  String get roomFormEditTitle;

  /// No description provided for @roomFormNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de sala'**
  String get roomFormNameLabel;

  /// No description provided for @roomFormCapacityLabel.
  ///
  /// In es, this message translates to:
  /// **'Capacidad (personas)'**
  String get roomFormCapacityLabel;

  /// No description provided for @roomFormSizeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tamaño (ej. 4x5m)'**
  String get roomFormSizeLabel;

  /// No description provided for @roomFormPricePerHourLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio por hora (€)'**
  String get roomFormPricePerHourLabel;

  /// No description provided for @roomFormEquipmentLabel.
  ///
  /// In es, this message translates to:
  /// **'Equipamiento (separado por comas)'**
  String get roomFormEquipmentLabel;

  /// No description provided for @roomFormRequiredField.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get roomFormRequiredField;

  /// No description provided for @roomFormSectionConfig.
  ///
  /// In es, this message translates to:
  /// **'Configuración de sala'**
  String get roomFormSectionConfig;

  /// No description provided for @roomFormMinBookingHoursLabel.
  ///
  /// In es, this message translates to:
  /// **'Horas mínimas por reserva'**
  String get roomFormMinBookingHoursLabel;

  /// No description provided for @roomFormMinBookingHoursHelp.
  ///
  /// In es, this message translates to:
  /// **'Contractual — mínimo de horas'**
  String get roomFormMinBookingHoursHelp;

  /// No description provided for @roomFormMaxDecibelsLabel.
  ///
  /// In es, this message translates to:
  /// **'Decibelios máximos (dB)'**
  String get roomFormMaxDecibelsLabel;

  /// No description provided for @roomFormMaxDecibelsHelp.
  ///
  /// In es, this message translates to:
  /// **'Ordenanzas municipales de ruido — nivel máximo'**
  String get roomFormMaxDecibelsHelp;

  /// No description provided for @roomFormAgeRestrictionLabel.
  ///
  /// In es, this message translates to:
  /// **'Restricción de edad mínima'**
  String get roomFormAgeRestrictionLabel;

  /// No description provided for @roomFormAgeRestrictionHelp.
  ///
  /// In es, this message translates to:
  /// **'LOPDGDD Art. 7 — edad mínima para usar la sala'**
  String get roomFormAgeRestrictionHelp;

  /// No description provided for @roomFormSectionPolicies.
  ///
  /// In es, this message translates to:
  /// **'Políticas'**
  String get roomFormSectionPolicies;

  /// No description provided for @roomFormCancellationPolicyLabel.
  ///
  /// In es, this message translates to:
  /// **'Política de cancelación'**
  String get roomFormCancellationPolicyLabel;

  /// No description provided for @roomFormCancellationPolicyHelp.
  ///
  /// In es, this message translates to:
  /// **'Directiva 2011/83/UE — cancelación y devolución'**
  String get roomFormCancellationPolicyHelp;

  /// No description provided for @roomFormAccessibleTitle.
  ///
  /// In es, this message translates to:
  /// **'Accesibilidad'**
  String get roomFormAccessibleTitle;

  /// No description provided for @roomFormAccessibleSubtitle.
  ///
  /// In es, this message translates to:
  /// **'RD 1/2013 — acceso movilidad reducida'**
  String get roomFormAccessibleSubtitle;

  /// No description provided for @roomFormActiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Sala activa'**
  String get roomFormActiveTitle;

  /// No description provided for @roomFormActiveSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Visible para reservas'**
  String get roomFormActiveSubtitle;

  /// No description provided for @roomFormCreateAction.
  ///
  /// In es, this message translates to:
  /// **'Crear sala'**
  String get roomFormCreateAction;

  /// No description provided for @roomFormSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar la sala.'**
  String get roomFormSaveError;

  /// No description provided for @roomFormPhotosTitle.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get roomFormPhotosTitle;

  /// No description provided for @roomFormAttachPhotos.
  ///
  /// In es, this message translates to:
  /// **'Adjuntar fotos'**
  String get roomFormAttachPhotos;

  /// No description provided for @studiosListTitleForRehearsal.
  ///
  /// In es, this message translates to:
  /// **'Reservar sala para ensayo'**
  String get studiosListTitleForRehearsal;

  /// No description provided for @studiosListEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay estudios disponibles.'**
  String get studiosListEmpty;

  /// No description provided for @studiosListLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más estudios'**
  String get studiosListLoadMore;

  /// No description provided for @studioRoomsTitle.
  ///
  /// In es, this message translates to:
  /// **'Salas del estudio'**
  String get studioRoomsTitle;

  /// No description provided for @studioRoomsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay salas disponibles en este estudio.'**
  String get studioRoomsEmpty;

  /// No description provided for @musicianBookingsLoginRequired.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para ver tus reservas.'**
  String get musicianBookingsLoginRequired;

  /// No description provided for @musicianBookingsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las reservas.'**
  String get musicianBookingsLoadError;

  /// No description provided for @musicianBookingsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get musicianBookingsRetry;

  /// No description provided for @musicianBookingsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron reservas.'**
  String get musicianBookingsEmpty;

  /// No description provided for @musicianBookingsTitle.
  ///
  /// In es, this message translates to:
  /// **'MIS RESERVAS'**
  String get musicianBookingsTitle;

  /// No description provided for @musicianBookingsUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximas reservas'**
  String get musicianBookingsUpcoming;

  /// No description provided for @musicianBookingsHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get musicianBookingsHistory;

  /// No description provided for @musicianBookingsLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más reservas'**
  String get musicianBookingsLoadMore;

  /// No description provided for @bookingStatusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'confirmada'**
  String get bookingStatusConfirmed;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'cancelada'**
  String get bookingStatusCancelled;

  /// No description provided for @bookingStatusRefunded.
  ///
  /// In es, this message translates to:
  /// **'reembolsada'**
  String get bookingStatusRefunded;

  /// No description provided for @bookingStatusPending.
  ///
  /// In es, this message translates to:
  /// **'pendiente'**
  String get bookingStatusPending;

  /// No description provided for @roomCardPricePerHour.
  ///
  /// In es, this message translates to:
  /// **'{price}€ /h'**
  String roomCardPricePerHour(String price);

  /// No description provided for @roomCardCapacity.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{# persona} other{# personas}}'**
  String roomCardCapacity(int count);

  /// No description provided for @studioCardViewRooms.
  ///
  /// In es, this message translates to:
  /// **'Ver salas'**
  String get studioCardViewRooms;

  /// No description provided for @eventsNewEventButton.
  ///
  /// In es, this message translates to:
  /// **'Nuevo evento'**
  String get eventsNewEventButton;

  /// No description provided for @eventsViewDetails.
  ///
  /// In es, this message translates to:
  /// **'Ver detalles'**
  String get eventsViewDetails;

  /// No description provided for @eventsViewTextSheet.
  ///
  /// In es, this message translates to:
  /// **'Ver ficha en texto'**
  String get eventsViewTextSheet;

  /// No description provided for @eventsCopyFormat.
  ///
  /// In es, this message translates to:
  /// **'Copiar formato'**
  String get eventsCopyFormat;

  /// No description provided for @eventsCopySheetTooltip.
  ///
  /// In es, this message translates to:
  /// **'Copiar ficha'**
  String get eventsCopySheetTooltip;

  /// No description provided for @onboardingInfluencesTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus influencias'**
  String get onboardingInfluencesTitle;

  /// No description provided for @onboardingInfluencesDescription.
  ///
  /// In es, this message translates to:
  /// **'Agrega las bandas o artistas que más te han influenciado, organizados por estilo.'**
  String get onboardingInfluencesDescription;

  /// No description provided for @onboardingInfluencesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has agregado influencias.'**
  String get onboardingInfluencesEmpty;

  /// No description provided for @affinityStyleLabel.
  ///
  /// In es, this message translates to:
  /// **'Estilo'**
  String get affinityStyleLabel;

  /// No description provided for @affinityArtistBandLabel.
  ///
  /// In es, this message translates to:
  /// **'Artista / Banda'**
  String get affinityArtistBandLabel;

  /// No description provided for @affinitySuggestedOptionsLabel.
  ///
  /// In es, this message translates to:
  /// **'Opciones sugeridas'**
  String get affinitySuggestedOptionsLabel;

  /// No description provided for @affinityNoMatchesForStyle.
  ///
  /// In es, this message translates to:
  /// **'Sin coincidencias para este estilo.'**
  String get affinityNoMatchesForStyle;

  /// No description provided for @affinityAddButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get affinityAddButton;

  /// No description provided for @affinityAddTooltip.
  ///
  /// In es, this message translates to:
  /// **'Agregar afinidad'**
  String get affinityAddTooltip;

  /// No description provided for @profileAffinityTitle.
  ///
  /// In es, this message translates to:
  /// **'Afinidades musicales'**
  String get profileAffinityTitle;

  /// No description provided for @profileAffinityDescription.
  ///
  /// In es, this message translates to:
  /// **'Agrega o quita artistas que representen tus influencias por estilo.'**
  String get profileAffinityDescription;

  /// No description provided for @profileAffinityEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin afinidades registradas.'**
  String get profileAffinityEmpty;

  /// No description provided for @roomDetailPricePerHour.
  ///
  /// In es, this message translates to:
  /// **'{price}€ / hora'**
  String roomDetailPricePerHour(String price);

  /// No description provided for @roomDetailCapacity.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{Capacidad: # persona} other{Capacidad: # personas}}'**
  String roomDetailCapacity(int count);

  /// No description provided for @roomDetailSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño: {size}'**
  String roomDetailSize(String size);

  /// No description provided for @roomDetailEquipmentTitle.
  ///
  /// In es, this message translates to:
  /// **'Equipamiento'**
  String get roomDetailEquipmentTitle;

  /// No description provided for @roomDetailBookForRehearsal.
  ///
  /// In es, this message translates to:
  /// **'Reservar para ensayo'**
  String get roomDetailBookForRehearsal;

  /// No description provided for @roomDetailBookRoom.
  ///
  /// In es, this message translates to:
  /// **'Reservar sala'**
  String get roomDetailBookRoom;

  /// No description provided for @roomDetailBookingSuccessForRehearsal.
  ///
  /// In es, this message translates to:
  /// **'Sala reservada para el ensayo por {total}€.'**
  String roomDetailBookingSuccessForRehearsal(String total);

  /// No description provided for @roomDetailBookingSuccess.
  ///
  /// In es, this message translates to:
  /// **'Reserva confirmada por {total}€.'**
  String roomDetailBookingSuccess(String total);

  /// No description provided for @roomDetailBookingError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la reserva.'**
  String get roomDetailBookingError;

  /// No description provided for @roomDetailPrefilledFromRehearsal.
  ///
  /// In es, this message translates to:
  /// **'Fecha y hora pre-rellenadas desde el ensayo'**
  String get roomDetailPrefilledFromRehearsal;

  /// No description provided for @roomDetailDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get roomDetailDateLabel;

  /// No description provided for @roomDetailSelectDate.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha'**
  String get roomDetailSelectDate;

  /// No description provided for @roomDetailStartTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora de inicio'**
  String get roomDetailStartTimeLabel;

  /// No description provided for @roomDetailSelectTime.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar hora'**
  String get roomDetailSelectTime;

  /// No description provided for @roomDetailDurationHours.
  ///
  /// In es, this message translates to:
  /// **'{hours, plural, one{Duración: # hora} other{Duración: # horas}}'**
  String roomDetailDurationHours(int hours);

  /// No description provided for @roomDetailMinBookingHours.
  ///
  /// In es, this message translates to:
  /// **'Reserva mínima: {hours}h'**
  String roomDetailMinBookingHours(int hours);

  /// No description provided for @roomDetailMaxDecibels.
  ///
  /// In es, this message translates to:
  /// **'Máx. decibelios: {decibels} dB'**
  String roomDetailMaxDecibels(String decibels);

  /// No description provided for @roomDetailMinimumAge.
  ///
  /// In es, this message translates to:
  /// **'Edad mínima: {age} años'**
  String roomDetailMinimumAge(int age);

  /// No description provided for @roomDetailAccessibleMobility.
  ///
  /// In es, this message translates to:
  /// **'Accesible movilidad reducida'**
  String get roomDetailAccessibleMobility;

  /// No description provided for @roomDetailCancellationPolicyTitle.
  ///
  /// In es, this message translates to:
  /// **'Política de cancelación'**
  String get roomDetailCancellationPolicyTitle;

  /// No description provided for @roomDetailPaymentMethodLabel.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get roomDetailPaymentMethodLabel;

  /// No description provided for @roomDetailVatLabel.
  ///
  /// In es, this message translates to:
  /// **'IVA (21%):'**
  String get roomDetailVatLabel;

  /// No description provided for @paymentMethodCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodTransfer.
  ///
  /// In es, this message translates to:
  /// **'Transferencia'**
  String get paymentMethodTransfer;

  /// No description provided for @paymentMethodCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodBizum.
  ///
  /// In es, this message translates to:
  /// **'Bizum'**
  String get paymentMethodBizum;

  /// No description provided for @roomDetailTotalPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio total:'**
  String get roomDetailTotalPriceLabel;

  /// No description provided for @roomDetailConfirmBookingForRehearsal.
  ///
  /// In es, this message translates to:
  /// **'Confirmar reserva'**
  String get roomDetailConfirmBookingForRehearsal;

  /// No description provided for @roomDetailConfirmBooking.
  ///
  /// In es, this message translates to:
  /// **'Confirmar reserva'**
  String get roomDetailConfirmBooking;

  /// No description provided for @homeExploreLabel.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get homeExploreLabel;

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aquí está tu resumen de hoy'**
  String get homeGreetingSubtitle;
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
