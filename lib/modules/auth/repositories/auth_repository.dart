import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_entity.dart';
import '../models/auth_exceptions.dart';

class AuthRepository {
  AuthRepository({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  Stream<UserEntity?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_mapUser);
  Stream<UserEntity?> get idTokenChanges =>
      _firebaseAuth.idTokenChanges().map(_mapUser);

  UserEntity? get currentUser => _mapUser(_firebaseAuth.currentUser);

  Future<void> refreshIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await user.getIdToken(true);
  }

  Future<UserEntity> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        debugPrint('[AuthRepository] User signed in: ${credential.user?.uid}');
      }
      return _mapUser(credential.user)!;
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
      return _mapUser(_firebaseAuth.currentUser ?? user)!;
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  Future<void> signOut() async {
    final uid = _firebaseAuth.currentUser?.uid;
    await _firebaseAuth.signOut();
    if (kDebugMode) {
      debugPrint('[AuthRepository] User signed out: $uid');
    }
  }

  AuthException _mapFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-disabled':
        return AuthException('La cuenta fue deshabilitada. Contacta soporte.');
      case 'user-not-found':
        return UserNotFoundException();
      case 'invalid-credential':
      case 'wrong-password':
        return InvalidCredentialsException();
      case 'email-already-in-use':
        return AuthException('Ya existe una cuenta con ese correo.');
      case 'weak-password':
        return AuthException('La contraseña debe tener al menos 6 caracteres.');
      case 'invalid-email':
        return AuthException('El correo no es válido.');
      default:
        return AuthException(
          error.message ?? 'Ocurrió un error de autenticación.',
        );
    }
  }

  UserEntity? _mapUser(User? firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    return UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? firebaseUser.email ?? 'Músico',
      photoUrl: firebaseUser.photoURL,
      isVerified: firebaseUser.emailVerified,
    );
  }
}
