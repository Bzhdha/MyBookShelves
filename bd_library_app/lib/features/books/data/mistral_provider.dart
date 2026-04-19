import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/app_logger.dart';
import '../../../models/bd_metadata.dart';
import '../../settings/data/llm_key_store.dart';
import 'llm_metadata_provider.dart';

/// Fournisseur de métadonnées livre/BD via l'API Mistral.
/// Format compatible OpenAI (chat completions).
class MistralProvider implements LlmMetadataProvider {
  MistralProvider(this._keyStore, [this._logger]);

  final LlmKeyStore _keyStore;
  final AppLogger? _logger;

  @override
  bool get isConfigured => _keyStore.isConfigured(LlmProvider.mistral);

  String? get _apiKey => _keyStore.getKey(LlmProvider.mistral);

  static const _systemPrompt = '''
Tu réponds UNIQUEMENT par un objet JSON valide, sans texte avant ou après.
Si tu ne trouves aucune information pour l'ISBN demandé, retourne un objet vide : {}.
''';

  @override
  Future<BdMetadata?> fetchByIsbn(String isbn) async {
    final key = _apiKey;
    if (key == null || key.trim().isEmpty) return null;

    final userContent = llmIsbnSearchUserPromptTemplate.replaceAll('[INSÉRER_ISBN_ICI]', isbn);

    try {
      final uri = Uri.parse('https://api.mistral.ai/v1/chat/completions');
      final body = {
        'model': 'mistral-small-latest',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': userContent},
        ],
        'response_format': {'type': 'json_object'},
        'max_tokens': 500,
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $key',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return null;

      final message = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
      final text = message?['content'] as String?;
      if (text == null || text.trim().isEmpty) return null;

      if (kDebugMode) {
        _logger?.log('MistralProvider.fetchByIsbn', {'isbn': isbn});
      }

      final meta = jsonDecode(text) as Map<String, dynamic>;
      return parseLlmMetadataJson(meta);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<LlmPromptResult?> fetchWithUserPrompt(String userPrompt) async {
    final key = _apiKey;
    if (key == null || key.trim().isEmpty) return null;
    try {
      final uri = Uri.parse('https://api.mistral.ai/v1/chat/completions');
      final body = {
        'model': 'mistral-small-latest',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'response_format': {'type': 'json_object'},
        'max_tokens': 500,
      };
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $key',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return null;
      final message = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
      final text = message?['content'] as String?;
      if (text == null || text.trim().isEmpty) return null;
      BdMetadata? parsed;
      try {
        final meta = jsonDecode(text) as Map<String, dynamic>;
        parsed = parseLlmMetadataJson(meta);
      } catch (_) {}
      return (rawResponse: text, parsed: parsed);
    } catch (_) {
      return null;
    }
  }
}
