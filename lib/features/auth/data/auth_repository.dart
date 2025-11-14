import 'dart:async';

import '../domain/user_entity.dart';
import 'auth_exceptions.dart';

class AuthRepository {
  final List<UserEntity> _users = [
    const UserEntity(id: '1', email: 'solista@example.com', displayName: 'Solista Demo', isVerified: true),
  ];

  Future<UserEntity> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final user = _users.firstWhere(
      (element) => element.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw InvalidCredentialsException(),
    );
    if (password.isEmpty) {
      throw InvalidCredentialsException();
    }
    return user;
  }

  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (password.length < 6) {
      throw AuthException('La contraseña debe tener al menos 6 caracteres.');
    }
    final exists = _users.any((element) => element.email.toLowerCase() == email.toLowerCase());
    if (exists) {
      throw AuthException('Ya existe una cuenta con ese correo.');
    }
    final user = UserEntity(id: DateTime.now().millisecondsSinceEpoch.toString(), email: email, displayName: displayName);
    _users.add(user);
    return user;
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final exists = _users.any((element) => element.email.toLowerCase() == email.toLowerCase());
    if (!exists) {
      throw UserNotFoundException();
    }
  }
}
