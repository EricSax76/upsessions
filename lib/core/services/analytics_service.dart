import 'dart:async';

class AnalyticsService {
  Future<void> log(String event, [Map<String, Object?> data = const {}]) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
