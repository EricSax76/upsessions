class StudioFormValidator {
  const StudioFormValidator._();

  static String? required(String? value, {String message = 'Required'}) {
    return value?.trim().isNotEmpty == true ? null : message;
  }

  static String? positiveInt(
    String? value, {
    String requiredMessage = 'Required',
    String invalidMessage = 'Must be an integer greater than 0',
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return requiredMessage;
    final parsed = int.tryParse(trimmed);
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
