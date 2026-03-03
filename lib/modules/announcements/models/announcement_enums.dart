/// Método preferido de contacto para un anuncio de búsqueda.
/// LSSI Art. 10 — información de contacto en servicios de la sociedad de la información.
enum ContactMethod { appMessage, email, phone }

/// Tipo de relación laboral ofrecida en el anuncio.
/// RD 1434/1992 — relaciones laborales especiales de artistas en espectáculos públicos.
enum AnnouncementContractType {
  autonomo,
  contratoLaboralEspecial,
  colaboracion,
}
