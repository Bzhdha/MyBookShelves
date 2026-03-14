import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../models/bd_metadata.dart';
import '../../settings/data/llm_key_store.dart';
import 'llm_metadata_provider.dart';

/// Fournisseur de métadonnées livre/BD via l'API OpenAI (ChatGPT).
/// Utilisé en secours lorsque BdTheque et OpenLibrary ne trouvent rien.
class ChatGptProvider implements LlmMetadataProvider {
  ChatGptProvider(this._keyStore);

  final LlmKeyStore _keyStore;

  @override
  bool get isConfigured => _keyStore.isConfigured(LlmProvider.openai);

  String? get _apiKey => _keyStore.getKey(LlmProvider.openai);

  static const _systemPrompt = '''
Tu es un assistant qui renvoie les métadonnées de livres ou bandes dessinées à partir d'un numéro ISBN.
Réponds UNIQUEMENT avec un objet JSON valide, sans texte avant ou après, avec les champs suivants (utilise null si inconnu) :
- "title" (string) : titre du livre ou de la série
- "authors" (array de strings) : noms des auteurs
- "publisher" (string) : éditeur
- "publishedDate" (string) : année ou date de publication
- "volumeNumber" (string) : numéro de tome si BD (ex: "1", "2")
''';

  @override
  Future<BdMetadata?> fetchByIsbn(String isbn) async {
    final key = _apiKey;
    if (key == null || key.trim().isEmpty) return null;

    try {
      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final body = {
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {
            'role': 'user',
            'content':
                'Donne les métadonnées du livre ou de la BD pour l\'ISBN suivant : $isbn',
          },
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

      final content = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
      final text = content?['content'] as String?;
      if (text == null || text.trim().isEmpty) return null;

      final meta = jsonDecode(text) as Map<String, dynamic>;
      return parseLlmMetadataJson(meta);
    } catch (_) {
      return null;
    }
  }
}
