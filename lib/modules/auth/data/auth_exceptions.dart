class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Las credenciales no son válidas.');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException() : super('Usuario no encontrado.');
}
