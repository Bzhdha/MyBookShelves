import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import '../../../models/bd_metadata.dart';

/// Regex pour extraire "Tome X" ou "tome X" du nom d'album.
final _tomeRegex = RegExp(r'Tome\s*(\d+)', caseSensitive: false);

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

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);

      if (decoded is! List || decoded.isEmpty) {
        return null;
      }

      final first = decoded.first;
      if (first is! Map<String, dynamic>) {
        return null;
      }

      final nom = (first['nom'] as String?)?.trim();
      final nomserie = (first['nomserie'] as String?)?.trim();
      final rawId = (first['id'] as String?)?.trim();

      // Numéro de tome extrait de "Tome 1", "Tome 2", etc.
      String? volumeNumber;
      if (nom != null && nom.isNotEmpty) {
        final match = _tomeRegex.firstMatch(nom);
        if (match != null) volumeNumber = match.group(1);
      }

      // Titre : nomserie si présent, sinon nom (sauf si c'est seulement "Tome X")
      String? titleFromApi = (nomserie != null && nomserie.isNotEmpty)
          ? nomserie
          : ((nom != null && nom.isNotEmpty) ? nom : null);
      if (titleFromApi != null &&
          titleFromApi.trim().length < 15 &&
          _tomeRegex.matchAsPrefix(titleFromApi.trim()) != null) {
        titleFromApi = null; // uniquement "Tome X", on va chercher le titre sur la page série
      }

      String? title = titleFromApi;
      List<String>? authors;
      String? publisher;

      // Dès qu'on a un id (ex: "26021/knight-club"), on charge la page série pour titre + auteurs + éditeur
      if (rawId != null && rawId.isNotEmpty) {
        final seriesMeta = await _fetchSeriesPage(rawId);
        if (seriesMeta != null) {
          title = title ?? seriesMeta.title;
          authors = seriesMeta.authors;
          publisher = seriesMeta.publisher;
        }
      }

      if (title == null || title.isEmpty) return null;

      return BdMetadata(
        title: title,
        authors: authors,
        publisher: publisher,
        coverUrl: null,
        volumeNumber: volumeNumber,
      );
    } catch (_) {
      return null;
    }
  }

  /// Charge la page série BdTheque pour extraire titre, auteurs, éditeur.
  /// URL utilisée : https://www.bdtheque.com/series/{id} (ex. .../series/26021/knight-club)
  Future<({String? title, List<String>? authors, String? publisher})?> _fetchSeriesPage(String seriesId) async {
    try {
      final path = seriesId.replaceAll(r'\', '/');
      final uri = Uri.parse('https://www.bdtheque.com/series/$path');

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'bd_library_app/1.0',
          'Accept': 'text/html,application/xhtml+xml',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return null;

      final doc = html_parser.parse(response.body);

      final title = doc.querySelector('h1')?.text.trim();
      if (title == null || title.isEmpty) return null;

      final authorLinks = doc.querySelectorAll('a[href*="auteurs="]');
      final authors = authorLinks
          .map((a) => a.text.trim())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();

      String? publisher;
      for (final th in doc.querySelectorAll('th')) {
        if (th.text.trim().toLowerCase() == 'editeur') {
          final td = th.parent?.querySelector('td');
          if (td != null) {
            final link = td.querySelector('a');
            publisher = (link ?? td).text.trim();
            if (publisher.isEmpty) publisher = null;
          }
          break;
        }
      }

      return (title: title, authors: authors.isEmpty ? null : authors, publisher: publisher);
    } catch (_) {
      return null;
    }
  }
}
