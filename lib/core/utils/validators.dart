class Validators {
  static bool isValidEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  static bool isValidPassword(String value) {
    return value.length >= 8;
  }

  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
