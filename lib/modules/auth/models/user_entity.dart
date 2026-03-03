import 'package:flutter/foundation.dart';

/// Roles disponibles en la plataforma (RBAC).
enum UserRole { musician, manager, studio, admin }

/// Entidad de cuenta de usuario.
///
/// Campos normativos añadidos:
/// - [createdAt]             → RGPD Art. 30 — registro de actividades de tratamiento
/// - [lastLoginAt]           → RGPD Art. 32 — seguridad / detección de accesos no autorizados
/// - [acceptedTermsAt]       → LSSI Art. 23 / RGPD Art. 7 — prueba de aceptación de T&C
/// - [acceptedPrivacyAt]     → RGPD Art. 7.1 — consentimiento explícito a política de privacidad
/// - [dataProcessingConsent] → RGPD Art. 6 — base legal del tratamiento
/// - [marketingConsent]      → LSSI Art. 21 — consentimiento para comunicaciones comerciales
/// - [deletedAt]             → RGPD Art. 17 — derecho al olvido / soft-delete con TTL
/// - [locale]                → LSSI Art. 10 — idioma para comunicaciones legales
/// - [phoneNumber]           → LSSI Art. 10 — dato de contacto
/// - [role]                  → Seguridad / RBAC — musician, manager, studio, admin
@immutable
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.photoUrl,
    this.isVerified = false,
    this.lastLoginAt,
    this.acceptedTermsAt,
    this.acceptedPrivacyAt,
    this.dataProcessingConsent = false,
    this.marketingConsent = false,
    this.deletedAt,
    this.locale,
    this.phoneNumber,
    this.role = UserRole.musician,
  });

  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isVerified;

  // ── Normativa RGPD / LSSI ──────────────────────────────────────────────────
  /// RGPD Art. 30 — timestamp de creación de la cuenta.
  final DateTime createdAt;

  /// RGPD Art. 32 — último acceso; detección de accesos no autorizados.
  final DateTime? lastLoginAt;

  /// LSSI Art. 23 / RGPD Art. 7 — fecha en que el usuario aceptó los T&C.
  /// ⚠️ CRÍTICO: sin este campo no hay prueba de consentimiento válido.
  final DateTime? acceptedTermsAt;

  /// RGPD Art. 7.1 — fecha de aceptación explícita de la política de privacidad.
  /// ⚠️ CRÍTICO: sin este campo no hay prueba de consentimiento válido.
  final DateTime? acceptedPrivacyAt;

  /// RGPD Art. 6 — consentimiento al tratamiento de datos personales.
  final bool dataProcessingConsent;

  /// LSSI Art. 21 — opt-in para comunicaciones comerciales.
  final bool marketingConsent;

  /// RGPD Art. 17 — soft-delete; la cuenta se conserva con TTL antes de borrado definitivo.
  final DateTime? deletedAt;

  /// LSSI Art. 10 — idioma preferido (BCP 47, ej. "es", "en", "ca").
  final String? locale;

  /// LSSI Art. 10 — teléfono de contacto para ciertas transacciones.
  final String? phoneNumber;

  // ── Seguridad / RBAC ───────────────────────────────────────────────────────
  /// Rol del usuario en la plataforma.
  final UserRole role;

  /// Indica si la cuenta está activa (no borrada con soft-delete).
  bool get isActive => deletedAt == null;

  /// Indica si el usuario ha otorgado los dos consentimientos críticos del RGPD.
  bool get hasValidConsent =>
      acceptedTermsAt != null && acceptedPrivacyAt != null;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? acceptedTermsAt,
    DateTime? acceptedPrivacyAt,
    bool? dataProcessingConsent,
    bool? marketingConsent,
    DateTime? deletedAt,
    String? locale,
    String? phoneNumber,
    UserRole? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      acceptedTermsAt: acceptedTermsAt ?? this.acceptedTermsAt,
      acceptedPrivacyAt: acceptedPrivacyAt ?? this.acceptedPrivacyAt,
      dataProcessingConsent:
          dataProcessingConsent ?? this.dataProcessingConsent,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      deletedAt: deletedAt ?? this.deletedAt,
      locale: locale ?? this.locale,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }
}
