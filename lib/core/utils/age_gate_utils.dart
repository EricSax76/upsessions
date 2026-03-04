const int kMinimumMusicianAge = 14;
const int kLegalAdultAge = 18;

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

DateTime _asDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int? calculateAgeYears(DateTime? birthDate, {DateTime? now}) {
  if (birthDate == null) return null;
  final today = _asDate(now ?? DateTime.now());
  final normalizedBirthDate = _asDate(birthDate);
  if (normalizedBirthDate.isAfter(today)) return null;

  var age = today.year - normalizedBirthDate.year;
  final hadBirthdayThisYear =
      today.month > normalizedBirthDate.month ||
      (today.month == normalizedBirthDate.month &&
          today.day >= normalizedBirthDate.day);
  if (!hadBirthdayThisYear) age -= 1;
  return age;
}

bool isMusicianMinor(DateTime? birthDate, {DateTime? now}) {
  final age = calculateAgeYears(birthDate, now: now);
  return age != null && age < kLegalAdultAge;
}

bool isValidEmailAddress(String value) => _emailPattern.hasMatch(value.trim());

String? validateMusicianAgeGate({
  required DateTime? birthDate,
  required String legalGuardianEmail,
  required bool legalGuardianConsent,
  DateTime? now,
}) {
  if (birthDate == null) {
    return 'Selecciona tu fecha de nacimiento.';
  }

  final age = calculateAgeYears(birthDate, now: now);
  if (age == null) {
    return 'La fecha de nacimiento no es válida.';
  }

  if (age < kMinimumMusicianAge) {
    return 'Debes tener al menos 14 años para usar UpSessions.';
  }

  if (age < kLegalAdultAge) {
    final email = legalGuardianEmail.trim();
    if (email.isEmpty) {
      return 'Si eres menor de edad, necesitamos el email de tu tutor legal.';
    }
    if (!isValidEmailAddress(email)) {
      return 'El email del tutor legal no es válido.';
    }
    if (!legalGuardianConsent) {
      return 'Debes confirmar el consentimiento de tu tutor legal.';
    }
  }

  return null;
}
