import 'package:flutter/foundation.dart';

/// Utilidad para logging seguro que evita la exposición de información sensible (PII)
/// en entornos de producción (Release).
class AppLogger {
  /// Imprime mensajes de depuración solo si la app está en modo Debug.
  /// Úsalo para reemplazar `print()` o `debugPrint()` que contengan datos sensibles.
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[AppLogger] $message');
    }
  }

  /// Registra errores. En modo Debug los imprime en consola.
  /// En Release, este sería el punto de entrada para reportar a Crashlytics/Sentry,
  /// asegurándose de no enviar PII en el mensaje.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[AppLogger ERROR] $message');
      if (error != null) debugPrint(error.toString());
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    // TODO: Integrar reporte de errores en producción (ej. Firebase Crashlytics)
  }
}
