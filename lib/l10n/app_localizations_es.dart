// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'UPSESSIONS';

  @override
  String get welcome => 'Bienvenido a la comunidad musical.';

  @override
  String get searchMusicians => 'Busca músicos y bandas por todo el país.';

  @override
  String get announcements => 'Anuncios recientes';

  @override
  String get profile => 'Tu perfil musical';

  @override
  String get appBrandName => 'UPSESSIONS';

  @override
  String get appWelcomeTagline => 'Conecta tu música\nsin limite.';

  @override
  String get startButton => 'Comenzar';

  @override
  String get skip => 'Saltar';

  @override
  String get next => 'Siguiente';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get loginContinueWith => 'O continúa con';

  @override
  String continueWithProvider(String provider) {
    return 'Continuar con $provider';
  }

  @override
  String socialLoginPlaceholder(String provider) {
    return 'El inicio de sesión con $provider estará disponible pronto.';
  }

  @override
  String get providerEmail => 'Correo';

  @override
  String get providerFacebook => 'Facebook';

  @override
  String get providerApple => 'Apple';

  @override
  String get emailHint => 'Correo electrónico';

  @override
  String get emailRequired => 'Ingresa tu correo';

  @override
  String get emailInvalid => 'Ingresa un correo válido';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get passwordToggleShow => 'Mostrar contraseña';

  @override
  String get passwordToggleHide => 'Ocultar contraseña';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 4 caracteres';

  @override
  String get onboardingCollaborateTitle => 'Conecta con músicos reales';

  @override
  String get onboardingCollaborateDescription =>
      'Descubre instrumentistas y productores disponibles para sesiones en vivo o remotas.';

  @override
  String get onboardingShowcaseTitle => 'Muestra tu talento';

  @override
  String get onboardingShowcaseDescription => 'Comparte tu música';

  @override
  String get onboardingBookTitle => 'Tu centro de reservas musical';

  @override
  String get onboardingBookDescription =>
      'Coordina disponibilidad, contratos y pagos en pocos clicks.';

  @override
  String get eventsShowcasesTitle => 'Eventos y showcases';

  @override
  String get eventsShowcasesDescription =>
      'Planifica tus sesiones. Genera una ficha en formato texto para compartirla por correo o chat.';

  @override
  String get eventsActiveLabel => 'Eventos activos';

  @override
  String get eventsThisWeekLabel => 'Esta semana';

  @override
  String get eventsTotalCapacityLabel => 'Capacidad total';

  @override
  String get eventsEmptyMessage =>
      'Aún no hay eventos publicados. Sé el primero en crear uno desde la sección Eventos.';

  @override
  String get noEventsOnDate => 'No hay eventos registrados en esta fecha.';

  @override
  String get navMusicians => 'Músicos';

  @override
  String get navAnnouncements => 'Anuncios';

  @override
  String get navEvents => 'Eventos';

  @override
  String get navRehearsals => 'Ensayos';

  @override
  String get musicianContactTitle => '¿Te interesa colaborar?';

  @override
  String get musicianContactDescription =>
      'Conecta por chat para coordinar detalles y disponibilidad.';

  @override
  String get musicianContactLoading => 'Abriendo...';

  @override
  String get musicianContactButton => 'Contactar';

  @override
  String get musicianInviteButton => 'Invitar';

  @override
  String eventsForDate(String dateLabel) {
    return 'Eventos para $dateLabel';
  }

  @override
  String eventsPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# personas',
      one: '# persona',
    );
    return '$_temp0';
  }
}
