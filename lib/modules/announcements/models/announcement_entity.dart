import 'package:flutter/foundation.dart';

import 'announcement_enums.dart';

@immutable
class AnnouncementEntity {
  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.city,
    required this.author,
    required this.authorId,
    required this.province,
    required this.instrument,
    required this.styles,
    required this.publishedAt,
    this.imageUrl,
    // ── Campos normativos ──────────────────────────────────────────
    /// RGPD Art. 5.1.e — limitación del plazo de conservación.
    this.expiresAt,
    /// RGPD Art. 5.1.d — exactitud; se actualiza en cada modificación.
    this.updatedAt,
    /// Estado del anuncio; false oculta el anuncio del feed público.
    this.isActive = true,
    /// LSSI Art. 10 — canal preferido de contacto.
    this.contactMethod,
    /// RD 1434/1992 — caché o presupuesto ofrecido (texto libre, ej. "300 €").
    this.budget,
    /// RD 1434/1992 — tipo de relación laboral ofrecida.
    this.contractType,
    /// Años de experiencia mínimos solicitados.
    this.requiredExperienceYears,
    /// Si se acepta colaboración en remoto (grabación, sesiones online).
    this.locationRemote = false,
  });

  final String id;
  final String title;
  final String body;
  final String city;
  final String author;
  /// UID del músico autor
  final String authorId;
  final String province;
  final String instrument;
  final List<String> styles;
  final DateTime publishedAt;
  final String? imageUrl;

  // ── Campos normativos ────────────────────────────────────────────
  final DateTime? expiresAt;
  final DateTime? updatedAt;
  final bool isActive;
  final ContactMethod? contactMethod;
  final String? budget;
  final AnnouncementContractType? contractType;
  final int? requiredExperienceYears;
  final bool locationRemote;

  AnnouncementEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? city,
    String? author,
    String? authorId,
    String? province,
    String? instrument,
    List<String>? styles,
    DateTime? publishedAt,
    String? imageUrl,
    DateTime? expiresAt,
    DateTime? updatedAt,
    bool? isActive,
    ContactMethod? contactMethod,
    String? budget,
    AnnouncementContractType? contractType,
    int? requiredExperienceYears,
    bool? locationRemote,
  }) {
    return AnnouncementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      city: city ?? this.city,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      province: province ?? this.province,
      instrument: instrument ?? this.instrument,
      styles: styles ?? this.styles,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      contactMethod: contactMethod ?? this.contactMethod,
      budget: budget ?? this.budget,
      contractType: contractType ?? this.contractType,
      requiredExperienceYears:
          requiredExperienceYears ?? this.requiredExperienceYears,
      locationRemote: locationRemote ?? this.locationRemote,
    );
  }
}
