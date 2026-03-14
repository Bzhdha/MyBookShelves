import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage chiffré de la clé API OpenAI (Keychain / Keystore selon la plateforme).
/// Permet de charger, sauvegarder et supprimer la clé.
class OpenAiKeyStore extends ChangeNotifier {
  OpenAiKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'openai_api_key';

  final FlutterSecureStorage _storage;

  String? _apiKey;

  /// Clé en mémoire (null si non chargée ou non configurée).
  String? get apiKey => _apiKey;

  /// True si une clé non vide est disponible.
  bool get isConfigured =>
      _apiKey != null && _apiKey!.trim().isNotEmpty;

  /// Charge la clé depuis le stockage sécurisé.
  Future<void> load() async {
    try {
      _apiKey = await _storage.read(key: _key);
      notifyListeners();
    } catch (_) {
      _apiKey = null;
      notifyListeners();
    }
  }

  /// Enregistre la clé (chiffrée) et met à jour le cache.
  Future<void> save(String? key) async {
    try {
      if (key == null || key.trim().isEmpty) {
        await _storage.delete(key: _key);
        _apiKey = null;
      } else {
        await _storage.write(key: _key, value: key.trim());
        _apiKey = key.trim();
      }
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  /// Supprime la clé du stockage.
  Future<void> clear() async => save(null);
}
