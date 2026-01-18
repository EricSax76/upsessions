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
  String get registerPageSubtitle => 'Únete a la red de Solo Músicos';

  @override
  String get registerPageLoginPrompt => '¿Ya tienes cuenta? Inicia sesión';

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
  String get rehearsalsPageSubtitle => 'Gestiona los ensayos de tu grupo';

  @override
  String get rehearsalsSummaryTitle => 'Resumen';

  @override
  String rehearsalsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# ensayos programados',
      one: '1 ensayo programado',
    );
    return '$_temp0';
  }

  @override
  String get rehearsalsNextLabel => 'Próximo';

  @override
  String get rehearsalsTotalStat => 'Total Ensayos';

  @override
  String get rehearsalsNoUpcoming => 'Sin programar';

  @override
  String get rehearsalsNewButton => 'Nuevo Ensayo';

  @override
  String get rehearsalsAddMusicianButton => 'Agregar Músico';

  @override
  String get rehearsalsOnlyAdmin => 'Solo Admin';

  @override
  String get rehearsalsFilterUpcoming => 'Próximos';

  @override
  String get rehearsalsFilterPast => 'Pasados';

  @override
  String get rehearsalsFilterAll => 'Todos';

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

  @override
  String get rehearsalsGroupsMyGroupsTab => 'Mis Grupos';

  @override
  String get rehearsalsGroupsAgendaTab => 'Agenda';

  @override
  String get rehearsalsGroupsSearchLabel => 'Buscar grupos';

  @override
  String get rehearsalsGroupsClearSearchTooltip => 'Limpiar búsqueda';

  @override
  String get rehearsalsGroupsErrorLoading => 'No pudimos cargar tus grupos.';

  @override
  String get rehearsalsGroupsRetryButton => 'Reintentar';

  @override
  String get rehearsalsGroupsNoResultsTitle => 'No hay resultados';

  @override
  String get rehearsalsGroupsNoResultsSubtitle =>
      'Prueba con otro nombre o limpia la búsqueda.';

  @override
  String get rehearsalsGroupsClearSearchButton => 'Limpiar';

  @override
  String rehearsalsGroupsCreateGroupError(String error) {
    return 'No se pudo crear el grupo: $error';
  }

  @override
  String get rehearsalsGroupsGoToGroupTitle => 'Ir a un grupo';

  @override
  String get rehearsalsGroupsGroupIdLabel => 'ID del grupo';

  @override
  String get rehearsalsGroupsGroupIdHint => 'Ej. 6qDBI5b0LnybgBSF5KHU';

  @override
  String get rehearsalsGroupsGoButton => 'Ir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get error => 'Error';

  @override
  String get rehearsalsGroupsAgendaNoRehearsalsTitle => 'No hay ensayos';

  @override
  String get rehearsalsGroupsAgendaNoRehearsalsSubtitle =>
      'Aquí verás tus próximos ensayos de todos tus grupos.';

  @override
  String get homeUpcomingEventsTitle => 'Próximos eventos';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get homeRecommendedTitle => 'Recomendados para ti';

  @override
  String get homeRecommendedSubtitle => 'Basado en tus estilos favoritos';

  @override
  String get homeNewTalentTitle => 'Nuevos talentos';

  @override
  String get homeNewTalentSubtitle => 'Músicos recién llegados a la comunidad';

  @override
  String get homeExploreByInstrumentTitle => 'Explora por instrumento';

  @override
  String get homeExploreByInstrumentSubtitle =>
      'Filtra por instrumento para encontrar a tu próximo colaborador.';

  @override
  String rehearsalsSidebarErrorLoading(String error) {
    return 'Error cargando grupos: $error';
  }

  @override
  String get rehearsalsSidebarNewGroupLabel => 'Nuevo grupo';

  @override
  String get rehearsalsSidebarEmptyPrompt => 'Crea un grupo para empezar.';

  @override
  String rehearsalsSidebarRoleLabel(String role) {
    return 'Rol: $role';
  }

  @override
  String get rehearsalsSidebarCreateGroupTitle => 'Crear grupo';

  @override
  String get rehearsalsSidebarGroupNameLabel => 'Nombre';

  @override
  String get rehearsalsSidebarGroupNameHint => 'Ej. Banda X';

  @override
  String get create => 'Crear';

  @override
  String get userSidebarTitle => 'Tu panel';

  @override
  String get searchAdvancedTitle => 'Búsqueda avanzada';

  @override
  String get searchFiltersTitle => 'Filtros';

  @override
  String searchFiltersWithCount(int count) {
    return 'Filtros ($count)';
  }

  @override
  String get searchTopBarHint => 'Busca por nombre, estilo o instrumento';

  @override
  String get searchInstrumentLabel => 'Instrumento';

  @override
  String get searchInstrumentHint => 'Selecciona instrumento';

  @override
  String get searchStyleLabel => 'Estilo';

  @override
  String get searchStyleHint => 'Selecciona estilo';

  @override
  String get searchProfileTypeLabel => 'Tipo de perfil';

  @override
  String get searchProfileTypeHint => 'Selecciona tipo';

  @override
  String get searchProvinceLabel => 'Provincia';

  @override
  String get searchProvinceHint => 'Selecciona provincia';

  @override
  String get searchCityLabel => 'Ciudad';

  @override
  String get searchCityHint => 'Selecciona ciudad';

  @override
  String get searchCityUnavailable => 'Sin ciudades disponibles';

  @override
  String get searchClearFilters => 'Quitar filtros';

  @override
  String get searchAction => 'Buscar';

  @override
  String get searchGenderLabel => 'Género';

  @override
  String get searchGenderHint => 'Selecciona género';

  @override
  String get searchUnassignedOption => 'Sin asignar';

  @override
  String get searchAnyOption => 'Cualquiera';

  @override
  String get searchFemaleOption => 'Femenino';

  @override
  String get searchMaleOption => 'Masculino';

  @override
  String get searchAdvancedFiltersTitle => 'Filtros avanzados';

  @override
  String get searchAdvancedFiltersSubtitle => 'Toca para ajustar los filtros';

  @override
  String get searchProvincesLoadHint =>
      'Carga provincias españolas desde Firestore (metadata/geography.provinces).';

  @override
  String get searchCitiesLoadHint =>
      'Añade ciudades por provincia en Firestore (metadata/geography.citiesByProvince).';
}
