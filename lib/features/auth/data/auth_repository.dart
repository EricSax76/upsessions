import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../domain/user_entity.dart';
import 'auth_exceptions.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<UserEntity?> get authStateChanges => _firebaseAuth.authStateChanges().map(_mapUser);

  UserEntity? get currentUser => _mapUser(_firebaseAuth.currentUser);

  Future<UserEntity> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
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
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
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
    await _firebaseAuth.signOut();
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
        return AuthException(error.message ?? 'Ocurrió un error de autenticación.');
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
