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
  String get providerGoogle => 'Google';

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
  String get eventsEmptyTitle => 'No hay eventos';

  @override
  String get eventsEmptyMessage =>
      'Aún no hay eventos publicados. Sé el primero en crear uno desde la sección Eventos.';

  @override
  String get announcementsEmptyTitle => 'No hay anuncios';

  @override
  String get announcementsEmptySubtitle =>
      'Publica el primero o vuelve más tarde.';

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
  String rehearsalsErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get rehearsalsGroupFallbackName => 'Grupo';

  @override
  String rehearsalsCreateError(String error) {
    return 'No se pudo crear el ensayo: $error';
  }

  @override
  String get rehearsalsEmptyTitle => 'Todavía no hay ensayos';

  @override
  String get rehearsalsEmptySubtitle =>
      'Crea el primero para empezar a armar el setlist.';

  @override
  String get rehearsalsFilterEmptyTitle => 'Sin resultados';

  @override
  String get rehearsalsFilterEmptyUpcoming => 'No hay ensayos próximos.';

  @override
  String get rehearsalsFilterEmptyPast => 'Todavía no hay ensayos pasados.';

  @override
  String get rehearsalsFilterEmptyAll => 'No hay ensayos para mostrar.';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get saveAction => 'Guardar';

  @override
  String get closeAction => 'Cerrar';

  @override
  String get doneAction => 'Listo';

  @override
  String get removeAction => 'Quitar';

  @override
  String get rehearsalsDeleteTitle => 'Eliminar ensayo';

  @override
  String get rehearsalsDeleteMessage =>
      'Se eliminará el ensayo y su setlist. ¿Continuar?';

  @override
  String get rehearsalsDeleteSuccess => 'Ensayo eliminado.';

  @override
  String rehearsalsDeleteError(String error) {
    return 'No se pudo eliminar el ensayo: $error';
  }

  @override
  String get rehearsalsEditTitle => 'Editar ensayo';

  @override
  String get rehearsalsUpdateSuccess => 'Ensayo actualizado.';

  @override
  String rehearsalsUpdateError(String error) {
    return 'No se pudo actualizar el ensayo: $error';
  }

  @override
  String setlistAddError(String error) {
    return 'No se pudo agregar: $error';
  }

  @override
  String get setlistEditSongTitle => 'Editar canción';

  @override
  String setlistUpdateError(String error) {
    return 'No se pudo actualizar: $error';
  }

  @override
  String get setlistDeleteItemTitle => 'Eliminar item';

  @override
  String setlistDeleteItemMessage(String itemTitle) {
    return 'Eliminar \"$itemTitle\" del setlist?';
  }

  @override
  String setlistDeleteError(String error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String get setlistCopyNoPrevious => 'No hay ensayos previos para copiar.';

  @override
  String get setlistCopyDialogTitle => 'Copiar setlist';

  @override
  String setlistCopyDialogMessage(String dateLabel) {
    return 'Copiar el setlist del ensayo $dateLabel a este ensayo?';
  }

  @override
  String get setlistCopyAppendAction => 'Agregar al final';

  @override
  String get setlistCopyReplaceAction => 'Reemplazar';

  @override
  String get setlistCopySuccess => 'Setlist copiado.';

  @override
  String setlistCopyError(String error) {
    return 'No se pudo copiar el setlist: $error';
  }

  @override
  String setlistReorderError(String error) {
    return 'No se pudo reordenar el setlist: $error';
  }

  @override
  String get rehearsalDetailTitle => 'Ensayo';

  @override
  String get rehearsalDetailDeleteTooltip => 'Eliminar ensayo';

  @override
  String get rehearsalDetailSetlistEmpty => 'No hay canciones en el setlist';

  @override
  String rehearsalDetailSetlistTitle(int count) {
    return 'Setlist ($count)';
  }

  @override
  String get rehearsalDetailCopyPreviousAction => 'Copiar del anterior';

  @override
  String get rehearsalDetailAddSongAction => 'Agregar canción';

  @override
  String get rehearsalDetailInfoTitle => 'Detalles';

  @override
  String get rehearsalDetailStartLabel => 'Inicio';

  @override
  String get rehearsalDetailEndLabel => 'Fin';

  @override
  String get rehearsalDetailLocationLabel => 'Ubicación';

  @override
  String get rehearsalDetailRoomTitle => 'Sala de Ensayo';

  @override
  String get rehearsalDetailBookRoomAction => 'Reservar';

  @override
  String get rehearsalDetailNoRoomBooked => 'No hay sala reservada';

  @override
  String get rehearsalDetailRoomConfirmed => 'Confirmada';

  @override
  String get rehearsalDetailNotesTitle => 'Notas';

  @override
  String get setlistTableHeaderTitle => 'Título';

  @override
  String get setlistTableHeaderKey => 'Tonalidad';

  @override
  String get setlistTableHeaderBpm => 'BPM';

  @override
  String get setlistTableHeaderNotes => 'Notas';

  @override
  String get setlistTableUntitledSong => 'Sin título';

  @override
  String get setlistTableDeleteTooltip => 'Quitar del setlist';

  @override
  String get setlistTableBpmUnit => 'BPM';

  @override
  String get setlistItemAddSongTitle => 'Agregar canción';

  @override
  String get setlistItemAddAction => 'Agregar';

  @override
  String get setlistItemSongLabel => 'Canción';

  @override
  String get setlistItemSongHint => 'Ej. Autumn Leaves';

  @override
  String get setlistItemKeyLabel => 'Tono';

  @override
  String get setlistItemTempoLabel => 'Tempo (bpm)';

  @override
  String get setlistItemOrderLabel => 'Orden';

  @override
  String get setlistItemNotesLabel => 'Notas';

  @override
  String get setlistItemLinkLabel => 'Enlace (YouTube, etc.)';

  @override
  String get setlistItemLinkHint => 'https://…';

  @override
  String get setlistItemSheetSelected => 'Partitura seleccionada';

  @override
  String get setlistItemUploadSheet => 'Subir partitura';

  @override
  String get rehearsalDialogPickDateTime => 'Elegir fecha/hora';

  @override
  String get rehearsalDialogOptional => 'Opcional';

  @override
  String get rehearsalDialogNewTitle => 'Nuevo ensayo';

  @override
  String get rehearsalDialogStartLabel => 'Inicio';

  @override
  String get rehearsalDialogEndLabel => 'Fin';

  @override
  String get rehearsalDialogRemoveEndTooltip => 'Quitar fin';

  @override
  String get rehearsalDialogLocationLabel => 'Lugar';

  @override
  String get rehearsalDialogLocationHint => 'Ej. Sala 2 / Estudio';

  @override
  String get rehearsalDialogNotesLabel => 'Notas';

  @override
  String get rehearsalDialogNotesHint => 'Ej. Traer metrónomo';

  @override
  String get rehearsalDialogCreateAction => 'Crear';

  @override
  String get rehearsalDialogEndBeforeStartError =>
      'El fin no puede ser antes del inicio.';

  @override
  String get inviteDialogTitle => 'Agregar músico';

  @override
  String get inviteSearchLabel => 'Buscar por nombre';

  @override
  String get inviteSearchHint => 'Ej. ana';

  @override
  String get inviteTypeAtLeastOneCharacter => 'Escribe al menos 1 carácter.';

  @override
  String get inviteNoResults => 'Sin resultados.';

  @override
  String get inviteCreatedTitle => 'Invitación creada';

  @override
  String inviteCreatedFor(String name) {
    return 'Para: $name';
  }

  @override
  String get inviteCopyLinkAction => 'Copiar link';

  @override
  String get inviteLinkCopied => 'Link copiado.';

  @override
  String inviteCreateError(String error) {
    return 'No se pudo crear la invitación: $error';
  }

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
  String get rehearsalsGroupsErrorLoading => 'No pudimos cargar tus grupos.';

  @override
  String get rehearsalsGroupsRetryButton => 'Reintentar';

  @override
  String rehearsalsGroupsCreateGroupError(String error) {
    return 'No se pudo crear el grupo: $error';
  }

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
  String get homeNextRehearsalLabel => 'Próximo ensayo';

  @override
  String get homeNextRehearsalFallbackTitle => 'Ensayo programado';

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

  @override
  String get studiosCreateTitle => 'Registrar estudio';

  @override
  String get studiosCreateSectionStudioData => 'Datos del estudio';

  @override
  String get studiosCreateSectionLocation => 'Ubicación';

  @override
  String get studiosCreateSectionFiscal => 'Normativa fiscal y administrativa';

  @override
  String get studiosCreateSectionAccessibility => 'Accesibilidad y seguro';

  @override
  String get studiosCreateAction => 'Crear estudio';

  @override
  String get studiosCreateSuccess => 'Estudio creado correctamente.';

  @override
  String get studiosCreateAuthRequired =>
      'Debes iniciar sesión para crear un estudio.';

  @override
  String get studiosCreateInsuranceDateRequired =>
      'Selecciona la fecha de caducidad del seguro RC.';

  @override
  String get studiosCreateMaxCapacityInvalid =>
      'Aforo máximo inválido (debe ser > 0).';

  @override
  String get studioProfileUpdateSuccess => 'Perfil actualizado correctamente.';

  @override
  String get studioProfileUpdateError => 'No se pudieron guardar los cambios.';

  @override
  String get studioProfileImagesUpdateError =>
      'No se pudieron actualizar las imágenes.';

  @override
  String get studioProfileNotFound => 'No se encontró el estudio.';

  @override
  String get studioDashboardTabRooms => 'Mis salas';

  @override
  String get studioDashboardTabBookings => 'Reservas';

  @override
  String get studioDashboardRoomsTitle => 'Mis salas';

  @override
  String get studioDashboardAddRoom => 'Añadir sala';

  @override
  String get studioDashboardLoadMoreBookings => 'Cargar más reservas';

  @override
  String studioDashboardBookingTotal(String total) {
    return 'Total: $total€';
  }

  @override
  String studioDashboardRoomSummary(String capacity, String price) {
    return '$capacity personas • $price€/hora';
  }

  @override
  String get studioSidebarManagementTitle => 'GESTIÓN DE ESTUDIO';

  @override
  String get studioSidebarFallbackName => 'Mi estudio';

  @override
  String get studioSidebarSessionLabel => 'Sesión de estudio';

  @override
  String get studioSidebarMenuDashboard => 'Panel';

  @override
  String get studioSidebarMenuBookings => 'Mis reservas';

  @override
  String get studioSidebarMenuRooms => 'Mis salas';

  @override
  String get studioSidebarMenuProfile => 'Perfil del estudio';

  @override
  String get studioSidebarLogout => 'Cerrar sesión';

  @override
  String get studioSidebarThemeLight => 'Modo claro';

  @override
  String get studioSidebarThemeDark => 'Modo oscuro';

  @override
  String get studioEmptyNoStudioTitle => 'Aún no has registrado tu estudio';

  @override
  String get studioEmptyNoStudioSubtitle =>
      'Crea tu perfil de estudio para empezar a recibir reservas';

  @override
  String get studioEmptyNoStudioAction => 'Registrar estudio';

  @override
  String get studioEmptyNoRoomsTitle => 'No tienes salas registradas';

  @override
  String get studioEmptyNoRoomsSubtitle =>
      'Añade tu primera sala para comenzar a recibir reservas';

  @override
  String get studioEmptyNoBookingsTitle => 'Sin reservas pendientes';

  @override
  String get studioEmptyNoBookingsSubtitle =>
      'Cuando recibas reservas aparecerán aquí';

  @override
  String get roomFormAddTitle => 'Añadir sala';

  @override
  String get roomFormEditTitle => 'Editar sala';

  @override
  String get roomFormNameLabel => 'Nombre de sala';

  @override
  String get roomFormCapacityLabel => 'Capacidad (personas)';

  @override
  String get roomFormSizeLabel => 'Tamaño (ej. 4x5m)';

  @override
  String get roomFormPricePerHourLabel => 'Precio por hora (€)';

  @override
  String get roomFormEquipmentLabel => 'Equipamiento (separado por comas)';

  @override
  String get roomFormRequiredField => 'Campo obligatorio';

  @override
  String get roomFormSectionConfig => 'Configuración de sala';

  @override
  String get roomFormMinBookingHoursLabel => 'Horas mínimas por reserva';

  @override
  String get roomFormMinBookingHoursHelp => 'Contractual — mínimo de horas';

  @override
  String get roomFormMaxDecibelsLabel => 'Decibelios máximos (dB)';

  @override
  String get roomFormMaxDecibelsHelp =>
      'Ordenanzas municipales de ruido — nivel máximo';

  @override
  String get roomFormAgeRestrictionLabel => 'Restricción de edad mínima';

  @override
  String get roomFormAgeRestrictionHelp =>
      'LOPDGDD Art. 7 — edad mínima para usar la sala';

  @override
  String get roomFormSectionPolicies => 'Políticas';

  @override
  String get roomFormCancellationPolicyLabel => 'Política de cancelación';

  @override
  String get roomFormCancellationPolicyHelp =>
      'Directiva 2011/83/UE — cancelación y devolución';

  @override
  String get roomFormAccessibleTitle => 'Accesibilidad';

  @override
  String get roomFormAccessibleSubtitle =>
      'RD 1/2013 — acceso movilidad reducida';

  @override
  String get roomFormActiveTitle => 'Sala activa';

  @override
  String get roomFormActiveSubtitle => 'Visible para reservas';

  @override
  String get roomFormCreateAction => 'Crear sala';

  @override
  String get roomFormSaveError => 'Error al guardar la sala.';

  @override
  String get roomFormPhotosTitle => 'Fotos';

  @override
  String get roomFormAttachPhotos => 'Adjuntar fotos';

  @override
  String get studiosListTitleForRehearsal => 'Reservar sala para ensayo';

  @override
  String get studiosListEmpty => 'No hay estudios disponibles.';

  @override
  String get studiosListLoadMore => 'Cargar más estudios';

  @override
  String get studioRoomsTitle => 'Salas del estudio';

  @override
  String get studioRoomsEmpty => 'No hay salas disponibles en este estudio.';

  @override
  String get musicianBookingsLoginRequired =>
      'Inicia sesión para ver tus reservas.';

  @override
  String get musicianBookingsLoadError => 'No se pudieron cargar las reservas.';

  @override
  String get musicianBookingsRetry => 'Reintentar';

  @override
  String get musicianBookingsEmpty => 'No se encontraron reservas.';

  @override
  String get musicianBookingsTitle => 'MIS RESERVAS';

  @override
  String get musicianBookingsUpcoming => 'Próximas reservas';

  @override
  String get musicianBookingsHistory => 'Historial';

  @override
  String get musicianBookingsLoadMore => 'Cargar más reservas';

  @override
  String get bookingStatusConfirmed => 'confirmada';

  @override
  String get bookingStatusCancelled => 'cancelada';

  @override
  String get bookingStatusRefunded => 'reembolsada';

  @override
  String get bookingStatusPending => 'pendiente';

  @override
  String roomCardPricePerHour(String price) {
    return '$price€ /h';
  }

  @override
  String roomCardCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# personas',
      one: '# persona',
    );
    return '$_temp0';
  }

  @override
  String get studioCardViewRooms => 'Ver salas';

  @override
  String get eventsNewEventButton => 'Nuevo evento';

  @override
  String get eventsViewDetails => 'Ver detalles';

  @override
  String get eventsViewTextSheet => 'Ver ficha en texto';

  @override
  String get eventsCopyFormat => 'Copiar formato';

  @override
  String get eventsCopySheetTooltip => 'Copiar ficha';

  @override
  String get onboardingInfluencesTitle => 'Tus influencias';

  @override
  String get onboardingInfluencesDescription =>
      'Agrega las bandas o artistas que más te han influenciado, organizados por estilo.';

  @override
  String get onboardingInfluencesEmpty => 'Aún no has agregado influencias.';

  @override
  String get affinityStyleLabel => 'Estilo';

  @override
  String get affinityArtistBandLabel => 'Artista / Banda';

  @override
  String get affinitySuggestedOptionsLabel => 'Opciones sugeridas';

  @override
  String get affinityNoMatchesForStyle => 'Sin coincidencias para este estilo.';

  @override
  String get affinityAddButton => 'Agregar';

  @override
  String get affinityAddTooltip => 'Agregar afinidad';

  @override
  String get profileAffinityTitle => 'Afinidades musicales';

  @override
  String get profileAffinityDescription =>
      'Agrega o quita artistas que representen tus influencias por estilo.';

  @override
  String get profileAffinityEmpty => 'Sin afinidades registradas.';

  @override
  String roomDetailPricePerHour(String price) {
    return '$price€ / hora';
  }

  @override
  String roomDetailCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Capacidad: # personas',
      one: 'Capacidad: # persona',
    );
    return '$_temp0';
  }

  @override
  String roomDetailSize(String size) {
    return 'Tamaño: $size';
  }

  @override
  String get roomDetailEquipmentTitle => 'Equipamiento';

  @override
  String get roomDetailBookForRehearsal => 'Reservar para ensayo';

  @override
  String get roomDetailBookRoom => 'Reservar sala';

  @override
  String roomDetailBookingSuccessForRehearsal(String total) {
    return 'Sala reservada para el ensayo por $total€.';
  }

  @override
  String roomDetailBookingSuccess(String total) {
    return 'Reserva confirmada por $total€.';
  }

  @override
  String get roomDetailBookingError => 'No se pudo completar la reserva.';

  @override
  String get roomDetailPrefilledFromRehearsal =>
      'Fecha y hora pre-rellenadas desde el ensayo';

  @override
  String get roomDetailDateLabel => 'Fecha';

  @override
  String get roomDetailSelectDate => 'Seleccionar fecha';

  @override
  String get roomDetailStartTimeLabel => 'Hora de inicio';

  @override
  String get roomDetailSelectTime => 'Seleccionar hora';

  @override
  String roomDetailDurationHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Duración: # horas',
      one: 'Duración: # hora',
    );
    return '$_temp0';
  }

  @override
  String roomDetailMinBookingHours(int hours) {
    return 'Reserva mínima: ${hours}h';
  }

  @override
  String roomDetailMaxDecibels(String decibels) {
    return 'Máx. decibelios: $decibels dB';
  }

  @override
  String roomDetailMinimumAge(int age) {
    return 'Edad mínima: $age años';
  }

  @override
  String get roomDetailAccessibleMobility => 'Accesible movilidad reducida';

  @override
  String get roomDetailCancellationPolicyTitle => 'Política de cancelación';

  @override
  String get roomDetailPaymentMethodLabel => 'Método de pago';

  @override
  String get roomDetailVatLabel => 'IVA (21%):';

  @override
  String get paymentMethodCard => 'Tarjeta';

  @override
  String get paymentMethodTransfer => 'Transferencia';

  @override
  String get paymentMethodCash => 'Efectivo';

  @override
  String get paymentMethodBizum => 'Bizum';

  @override
  String get roomDetailTotalPriceLabel => 'Precio total:';

  @override
  String get roomDetailConfirmBookingForRehearsal => 'Confirmar reserva';

  @override
  String get roomDetailConfirmBooking => 'Confirmar reserva';

  @override
  String get homeExploreLabel => 'Explorar';

  @override
  String get homeGreetingSubtitle => 'Aquí está tu resumen de hoy';
}
