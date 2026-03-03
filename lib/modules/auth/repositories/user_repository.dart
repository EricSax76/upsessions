import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/user_dto.dart';
import '../models/user_entity.dart';

/// Repositorio para gestionar los datos extendidos del usuario en Firestore.
///
/// Firebase Auth proporciona uid, email, displayName, photoUrl, emailVerified.
/// Firestore (colección `users/{uid}`) almacena los campos normativos:
///   consentimientos, rol, locale, teléfono, timestamps de auditoría, etc.
class UserRepository {
  UserRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ── Lectura ────────────────────────────────────────────────────────────────

  /// Obtiene los datos extendidos del usuario desde Firestore.
  ///
  /// Si el documento no existe (usuario nuevo), se crea uno con los datos
  /// mínimos del [authUser] y [createdAt] = ahora.
  Future<UserEntity> fetchOrCreate(fb.User authUser) async {
    final doc = await _users.doc(authUser.uid).get();

    if (doc.exists && doc.data() != null) {
      final dto = UserDto.fromFirestore(authUser.uid, doc.data()!);
      return dto.toEntity();
    }

    // Primera vez: crear documento con datos mínimos
    final newDto = UserDto(
      id: authUser.uid,
      email: authUser.email ?? '',
      displayName: authUser.displayName ?? authUser.email ?? 'Músico',
      photoUrl: authUser.photoURL,
      isVerified: authUser.emailVerified,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    await _users.doc(authUser.uid).set(newDto.toFirestore());
    return newDto.toEntity();
  }

  // ── Escritura ──────────────────────────────────────────────────────────────

  /// Actualiza los consentimientos RGPD del usuario.
  ///
  /// ⚠️ CRÍTICO (RGPD Art. 7): registra las fechas de aceptación de T&C
  /// y política de privacidad. Sin estos timestamps no hay consentimiento válido.
  Future<void> recordConsent({
    required String userId,
    required bool dataProcessingConsent,
    required bool marketingConsent,
  }) async {
    final now = Timestamp.fromDate(DateTime.now());
    await _users.doc(userId).set({
      'dataProcessingConsent': dataProcessingConsent,
      'marketingConsent': marketingConsent,
      if (dataProcessingConsent) 'acceptedPrivacyAt': now,
      'acceptedTermsAt': now,
    }, SetOptions(merge: true));
  }

  /// Actualiza [lastLoginAt] en cada inicio de sesión.
  /// RGPD Art. 32: seguridad, detección de accesos no autorizados.
  Future<void> updateLastLogin(String userId) async {
    await _users.doc(userId).set({
      'lastLoginAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Soft-delete: establece [deletedAt] sin borrar el documento.
  /// RGPD Art. 17: gestión del derecho al olvido con TTL.
  Future<void> softDelete(String userId) async {
    await _users.doc(userId).set({
      'deletedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Actualiza campos opcionales del usuario (locale, teléfono, rol…).
  Future<void> updateUser(UserEntity user) async {
    final dto = UserDto(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      isVerified: user.isVerified,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      acceptedTermsAt: user.acceptedTermsAt,
      acceptedPrivacyAt: user.acceptedPrivacyAt,
      dataProcessingConsent: user.dataProcessingConsent,
      marketingConsent: user.marketingConsent,
      deletedAt: user.deletedAt,
      locale: user.locale,
      phoneNumber: user.phoneNumber,
      role: user.role,
    );
    await _users.doc(user.id).set(dto.toFirestore(), SetOptions(merge: true));
  }
}
