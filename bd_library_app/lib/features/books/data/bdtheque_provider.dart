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
      final couv = (first['couv'] as String?)?.trim();

      // URL couverture : base BdTheque pour les fichiers retournés par l'API (ex. "81890-couverture-bd-....jpg")
      String? coverUrlFromApi;
      if (couv != null && couv.isNotEmpty) {
        coverUrlFromApi = 'https://www.bdtheque.com/upload/$couv';
      }

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
      String? coverUrl = coverUrlFromApi;

      // Dès qu'on a un id (ex: "26021/knight-club"), on charge la page série pour titre + auteurs + éditeur + couverture
      if (rawId != null && rawId.isNotEmpty) {
        final seriesMeta = await _fetchSeriesPage(rawId);
        if (seriesMeta != null) {
          title = title ?? seriesMeta.title;
          authors = seriesMeta.authors;
          publisher = seriesMeta.publisher;
          coverUrl = seriesMeta.coverUrl ?? coverUrl;
        }
      }

      if (title == null || title.isEmpty) return null;

      return BdMetadata(
        title: title,
        authors: authors,
        publisher: publisher,
        coverUrl: coverUrl,
        volumeNumber: volumeNumber,
      );
    } catch (_) {
      return null;
    }
  }

  /// Charge la page série BdTheque pour extraire titre, auteurs, éditeur, couverture.
  /// URL utilisée : https://www.bdtheque.com/series/{id} (ex. .../series/26021/knight-club)
  Future<({String? title, List<String>? authors, String? publisher, String? coverUrl})?> _fetchSeriesPage(String seriesId) async {
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

      // Couverture : image dont l'URL contient "upload" ou "couv" (couverture), sinon première img avec src valide
      String? coverUrl;
      final imgs = doc.querySelectorAll('img[src]');
      for (final img in imgs) {
        final src = img.attributes['src']?.trim();
        if (src == null || src.isEmpty) continue;
        final lower = src.toLowerCase();
        if (lower.contains('upload') || lower.contains('couv')) {
          coverUrl = src.startsWith('http') ? src : 'https://www.bdtheque.com${src.startsWith('/') ? '' : '/'}$src';
          break;
        }
      }
      if (coverUrl == null) {
        for (final img in imgs) {
          final src = img.attributes['src']?.trim();
          if (src != null && src.isNotEmpty) {
            coverUrl = src.startsWith('http') ? src : 'https://www.bdtheque.com${src.startsWith('/') ? '' : '/'}$src';
            break;
          }
        }
      }

      return (title: title, authors: authors.isEmpty ? null : authors, publisher: publisher, coverUrl: coverUrl);
    } catch (_) {
      return null;
    }
  }
}
