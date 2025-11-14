import 'dart:async';

class RemoteConfigService {
  Future<Map<String, dynamic>> load() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const {
      'featureFlags': <String, bool>{},
    };
  }
}
