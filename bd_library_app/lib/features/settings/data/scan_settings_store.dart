import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paramètres du scan ISBN : photo couverture/dos et intervalle de changement de rectangle.
class ScanSettingsStore extends ChangeNotifier {
  static const _keyPhotoCoverEnabled = 'scan_photo_cover_enabled';
  static const _keyRectangleIntervalSeconds = 'scan_rectangle_interval_seconds';

  static const int defaultRectangleIntervalSeconds = 2;
  static const int minIntervalSeconds = 1;
  static const int maxIntervalSeconds = 10;

  bool _photoCoverEnabled = false;
  int _rectangleIntervalSeconds = defaultRectangleIntervalSeconds;

  bool get photoCoverEnabled => _photoCoverEnabled;
  int get rectangleIntervalSeconds => _rectangleIntervalSeconds;
  Duration get rectangleSwitchDuration =>
      Duration(seconds: _rectangleIntervalSeconds);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _photoCoverEnabled = prefs.getBool(_keyPhotoCoverEnabled) ?? false;
    _rectangleIntervalSeconds = (prefs.getInt(_keyRectangleIntervalSeconds) ??
        defaultRectangleIntervalSeconds)
        .clamp(minIntervalSeconds, maxIntervalSeconds);
    notifyListeners();
  }

  Future<void> setPhotoCoverEnabled(bool value) async {
    if (_photoCoverEnabled == value) return;
    _photoCoverEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPhotoCoverEnabled, value);
    notifyListeners();
  }

  Future<void> setRectangleIntervalSeconds(int seconds) async {
    final clamped = seconds.clamp(minIntervalSeconds, maxIntervalSeconds);
    if (_rectangleIntervalSeconds == clamped) return;
    _rectangleIntervalSeconds = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRectangleIntervalSeconds, clamped);
    notifyListeners();
  }
}
