import 'package:flutter/foundation.dart';

class SplashController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isReady = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isReady => _isReady;
  String? get error => _error;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      _isReady = true;
    } catch (error) {
      _error = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
