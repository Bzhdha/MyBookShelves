import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user's preference for biometric/device-credential app lock.
class AppLockStore extends ChangeNotifier {
  static const _keyEnabled = 'app_lock_enabled';

  bool _enabled = false;
  bool get enabled => _enabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_keyEnabled) ?? false;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
    _enabled = value;
    notifyListeners();
  }
}
