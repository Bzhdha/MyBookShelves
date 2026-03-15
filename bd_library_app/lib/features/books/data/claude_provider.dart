import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../models/bd_metadata.dart';
import '../../settings/data/llm_key_store.dart';
import 'llm_metadata_provider.dart';

/// Fournisseur de métadonnées livre/BD via l'API Anthropic (Claude).
class ClaudeProvider implements LlmMetadataProvider {
  ClaudeProvider(this._keyStore);

  final LlmKeyStore _keyStore;

  @override
  bool get isConfigured => _keyStore.isConfigured(LlmProvider.anthropic);

  String? get _apiKey => _keyStore.getKey(LlmProvider.anthropic);

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
      final uri = Uri.parse('https://api.anthropic.com/v1/messages');
      final body = {
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 500,
        'system': _systemPrompt,
        'messages': [
          {'role': 'user', 'content': userContent},
        ],
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': key,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final contentList = decoded['content'] as List<dynamic>?;
      if (contentList == null || contentList.isEmpty) return null;

      final firstBlock = contentList.first as Map<String, dynamic>?;
      final text = firstBlock?['text'] as String?;
      if (text == null || text.trim().isEmpty) return null;

      final meta = jsonDecode(text) as Map<String, dynamic>;
      return parseLlmMetadataJson(meta);
    } catch (_) {
      return null;
    }
  }
}
