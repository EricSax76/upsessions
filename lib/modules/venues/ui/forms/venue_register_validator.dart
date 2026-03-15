class VenueRegisterValidator {
  const VenueRegisterValidator._();

  static String? required(String? value, {String message = 'Requerido'}) {
    return value?.trim().isNotEmpty == true ? null : message;
  }

  static String? email(
    String? value, {
    String requiredMessage = 'Requerido',
    String invalidMessage = 'Correo inválido',
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return requiredMessage;
    if (!text.contains('@') || text.startsWith('@') || text.endsWith('@')) {
      return invalidMessage;
    }
    return null;
  }

  static String? password(
    String? value, {
    int minLength = 6,
    String message = 'Mínimo 6 caracteres',
  }) {
    final text = value ?? '';
    if (text.length < minLength) {
      return message;
    }
    return null;
  }
}
