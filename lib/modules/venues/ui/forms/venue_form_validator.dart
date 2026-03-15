class VenueFormValidator {
  const VenueFormValidator._();

  static String? required(String? value, {String message = 'Requerido'}) {
    return value?.trim().isNotEmpty == true ? null : message;
  }

  static String? email(
    String? value, {
    String requiredMessage = 'Requerido',
    String invalidMessage = 'Email no válido',
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return requiredMessage;
    if (!text.contains('@') || text.startsWith('@') || text.endsWith('@')) {
      return invalidMessage;
    }
    return null;
  }

  static String? positiveInt(
    String? value, {
    String requiredMessage = 'Requerido',
    String invalidMessage = 'Debe ser un entero > 0',
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return requiredMessage;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) {
      return invalidMessage;
    }
    return null;
  }

  static int? parsePositiveInt(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }
}
