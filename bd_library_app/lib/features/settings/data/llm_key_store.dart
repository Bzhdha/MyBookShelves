import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Type de fournisseur LLM pour la recherche de métadonnées par ISBN.
enum LlmProvider {
  openai,
  anthropic,
  mistral,
  groq,
}

extension LlmProviderExtension on LlmProvider {
  String get displayName {
    switch (this) {
      case LlmProvider.openai:
        return 'OpenAI (ChatGPT)';
      case LlmProvider.anthropic:
        return 'Anthropic (Claude)';
      case LlmProvider.mistral:
        return 'Mistral';
      case LlmProvider.groq:
        return 'Groq';
    }
  }

  /// Clé de stockage (openai_api_key pour rétrocompatibilité).
  String get storageKey {
    switch (this) {
      case LlmProvider.openai:
        return 'openai_api_key';
      case LlmProvider.anthropic:
        return 'llm_key_anthropic';
      case LlmProvider.mistral:
        return 'llm_key_mistral';
      case LlmProvider.groq:
        return 'llm_key_groq';
    }
  }
}

/// Stockage chiffré des clés API pour plusieurs fournisseurs LLM (OpenAI, Anthropic, Mistral, Groq).
/// Permet de charger, sauvegarder et supprimer une clé par fournisseur.
class LlmKeyStore extends ChangeNotifier {
  LlmKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  final Map<LlmProvider, String?> _keys = {
    for (final p in LlmProvider.values) p: null,
  };

  /// Clé en mémoire pour le fournisseur donné (null si non chargée ou non configurée).
  String? getKey(LlmProvider provider) => _keys[provider];

  /// True si une clé non vide est disponible pour ce fournisseur.
  bool isConfigured(LlmProvider provider) {
    final k = _keys[provider];
    return k != null && k.trim().isNotEmpty;
  }

  /// True si au moins un fournisseur a une clé configurée.
  bool get hasAnyConfigured =>
      LlmProvider.values.any((p) => isConfigured(p));

  /// Charge toutes les clés depuis le stockage sécurisé.
  Future<void> load() async {
    try {
      for (final p in LlmProvider.values) {
        _keys[p] = await _storage.read(key: p.storageKey);
      }
      notifyListeners();
    } catch (_) {
      for (final p in LlmProvider.values) {
        _keys[p] = null;
      }
      notifyListeners();
    }
  }

  /// Enregistre la clé pour le fournisseur (chiffrée) et met à jour le cache.
  Future<void> save(LlmProvider provider, String? key) async {
    try {
      final storageKey = provider.storageKey;
      if (key == null || key.trim().isEmpty) {
        await _storage.delete(key: storageKey);
        _keys[provider] = null;
      } else {
        await _storage.write(key: storageKey, value: key.trim());
        _keys[provider] = key.trim();
      }
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  /// Supprime la clé du fournisseur.
  Future<void> clear(LlmProvider provider) async => save(provider, null);
}
