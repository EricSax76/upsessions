import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_entity.dart';

/// DTO para serialización/deserialización de [UserEntity] en Firestore.
///
/// Los datos básicos (uid, email, displayName, photoUrl, emailVerified)
/// provienen de Firebase Auth. Este DTO almacena los campos adicionales
/// en la colección `users/{uid}` de Firestore.
class UserDto {
  const UserDto({
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
    this.dataProcessingLegalBasis = 'contract',
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
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? acceptedTermsAt;
  final DateTime? acceptedPrivacyAt;
  final bool dataProcessingConsent;
  final String dataProcessingLegalBasis;
  final bool marketingConsent;
  final DateTime? deletedAt;
  final String? locale;
  final String? phoneNumber;
  final UserRole role;

  /// Construye un [UserDto] a partir de un documento de Firestore.
  factory UserDto.fromFirestore(String id, Map<String, dynamic> data) {
    return UserDto(
      id: id,
      email: (data['email'] ?? '') as String,
      displayName: (data['displayName'] ?? '') as String,
      photoUrl: data['photoUrl'] as String?,
      isVerified: (data['isVerified'] as bool?) ?? false,
      createdAt: _toDateTime(data['createdAt']) ?? DateTime.now(),
      lastLoginAt: _toDateTime(data['lastLoginAt']),
      acceptedTermsAt: _toDateTime(data['acceptedTermsAt']),
      acceptedPrivacyAt: _toDateTime(data['acceptedPrivacyAt']),
      dataProcessingConsent: (data['dataProcessingConsent'] as bool?) ?? false,
      dataProcessingLegalBasis:
          (data['dataProcessingLegalBasis'] as String?) ?? 'contract',
      marketingConsent: (data['marketingConsent'] as bool?) ?? false,
      deletedAt: _toDateTime(data['deletedAt']),
      locale: data['locale'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      role: _roleFromString(data['role'] as String?),
    );
  }

  /// Serializa a mapa para Firestore (partial merge-safe).
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
      if (acceptedTermsAt != null)
        'acceptedTermsAt': Timestamp.fromDate(acceptedTermsAt!),
      if (acceptedPrivacyAt != null)
        'acceptedPrivacyAt': Timestamp.fromDate(acceptedPrivacyAt!),
      'dataProcessingConsent': dataProcessingConsent,
      'dataProcessingLegalBasis': dataProcessingLegalBasis,
      'marketingConsent': marketingConsent,
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
      if (locale != null) 'locale': locale,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'role': role.name,
    };
  }

  /// Fusiona los campos de Firebase Auth con los datos de Firestore.
  ///
  /// Usar cuando se tenga el [UserEntity] básico de Auth y el doc de Firestore.
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isVerified: isVerified,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      acceptedTermsAt: acceptedTermsAt,
      acceptedPrivacyAt: acceptedPrivacyAt,
      dataProcessingConsent: dataProcessingConsent,
      dataProcessingLegalBasis: dataProcessingLegalBasis,
      marketingConsent: marketingConsent,
      deletedAt: deletedAt,
      locale: locale,
      phoneNumber: phoneNumber,
      role: role,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static DateTime? _toDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  static UserRole _roleFromString(String? raw) {
    if (raw == null) return UserRole.musician;
    return UserRole.values.firstWhere(
      (r) => r.name == raw,
      orElse: () => UserRole.musician,
    );
  }
}
