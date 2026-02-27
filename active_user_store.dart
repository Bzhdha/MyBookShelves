import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère l'utilisateur actif (profil courant) côté appareil.
class ActiveUserStore extends ChangeNotifier {
  static const _key = 'active_user_id';

  String? _activeUserId;
  String? get activeUserId => _activeUserId;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _activeUserId = prefs.getString(_key);
    notifyListeners();
  }

  Future<void> setActiveUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, userId);
    }
    _activeUserId = userId;
    notifyListeners();
  }
}
