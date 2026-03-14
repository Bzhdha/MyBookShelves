import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bd_metadata.dart';

class BdThequeProvider {
  Future<BdMetadata?> fetchByIsbn(String isbn13) async {
    try {
      final uri = Uri.parse(
        'https://www.bdtheque.com/ajax/search/tomes/$isbn13',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'bd_library_app/1.0',
          'Accept': 'application/json, text/plain, */*',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        print('BDTheque HTTP ${response.statusCode}');
        return null;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List || decoded.isEmpty) {
        return null;
      }

      final first = decoded.first;
      if (first is! Map<String, dynamic>) {
        return null;
      }

      final nom = (first['nom'] as String?)?.trim();
      final nomSerie = (first['nomserie'] as String?)?.trim();
      final couv = (first['couv'] as String?)?.trim();

      // Choix du titre :
      // - priorité à nomserie (souvent plus parlant : "M-A-D, tome 2")
      // - sinon nom
      final title = (nomSerie != null && nomSerie.isNotEmpty)
          ? nomSerie
          : ((nom != null && nom.isNotEmpty) ? nom : null);

      // Si tu préfères combiner :
      // final title = [
      //   if (nomSerie != null && nomSerie.isNotEmpty) nomSerie,
      //   if (nom != null && nom.isNotEmpty) nom,
      // ].join(' - ').trim();

      // L'API retourne seulement le nom du fichier image.
      // Tant que tu n’as pas confirmé l’URL absolue attendue par le site,
      // mieux vaut ne pas renseigner coverUrl ici.
      // final coverUrl = couv != null && couv.isNotEmpty
      //     ? 'URL_ABSOLUE_A_CONFIRMER/$couv'
      //     : null;

      if (title == null || title.isEmpty) {
        return null;
      }

      return BdMetadata(
        title: title,
        coverUrl: null,
      );
    } catch (e) {
      print('Error BDTheque fetch: $e');
      return null;
    }
  }
}
