import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import '../../../models/bd_metadata.dart';

String _decodeHtmlEntities(String text) {
  final doc = html_parser.parseFragment(text);
  return doc.text ?? text;
}

/// Regex pour extraire "Tome X" ou "tome X" du titre ou sous-titre.
final _tomeRegex = RegExp(r'Tome\s*(\d+)', caseSensitive: false);

String? _httpsCoverUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://')) {
    return 'https://${url.substring(7)}';
  }
  return url;
}

class BdThequeProvider {
  /// Recherche sur BDthèque.com puis Google Books en fallback.
  Future<BdMetadata?> fetchByIsbn(String isbn13) async {
    final bdtheque = await _fetchFromBdtheque(isbn13);
    if (bdtheque != null) return bdtheque;
    return _fetchFromGoogleBooks(isbn13);
  }

  /// Scrape BDthèque.com pour les métadonnées BD françaises.
  Future<BdMetadata?> _fetchFromBdtheque(String isbn13) async {
    try {
      final searchUri = Uri.parse('https://www.bdtheque.com/search.php?crit=$isbn13');
      final searchResp = await http.get(searchUri, headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; bd_library_app/1.0)',
        'Accept': 'text/html,application/xhtml+xml',
      }).timeout(const Duration(seconds: 8));
      if (searchResp.statusCode != 200) return null;

      final searchDoc = html_parser.parse(utf8.decode(searchResp.bodyBytes));
      final albumLink = searchDoc.querySelector('a[href*="/album-"]');
      if (albumLink == null) return null;

      final href = albumLink.attributes['href'];
      if (href == null) return null;
      final albumUrl = href.startsWith('http') ? href : 'https://www.bdtheque.com$href';

      final albumResp = await http.get(Uri.parse(albumUrl), headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; bd_library_app/1.0)',
        'Accept': 'text/html,application/xhtml+xml',
      }).timeout(const Duration(seconds: 8));
      if (albumResp.statusCode != 200) return null;

      final doc = html_parser.parse(utf8.decode(albumResp.bodyBytes));

      String? title = doc.querySelector('h1')?.text.trim();
      String? volumeNumber;
      if (title != null) {
        final tomeMatch = _tomeRegex.firstMatch(title);
        if (tomeMatch != null) volumeNumber = tomeMatch.group(1);
      }

      List<String>? authors;
      final authorLinks = doc.querySelectorAll('a[href*="/auteur-"]');
      if (authorLinks.isNotEmpty) {
        authors = authorLinks.map((a) => a.text.trim()).where((s) => s.isNotEmpty).toSet().toList();
      }

      String? publisher;
      final editeurLink = doc.querySelector('a[href*="/editeur-"]');
      if (editeurLink != null) publisher = editeurLink.text.trim();

      String? description;
      final infoDiv = doc.querySelector('.album-info, .info, .resume');
      if (infoDiv != null) description = infoDiv.text.trim();

      String? coverUrl;
      final coverImg = doc.querySelector('img[src*="/Couvertures/"]');
      if (coverImg != null) {
        coverUrl = coverImg.attributes['src'];
        if (coverUrl != null && !coverUrl.startsWith('http')) {
          coverUrl = 'https://www.bdtheque.com$coverUrl';
        }
      }

      if (title == null || title.isEmpty) return null;

      return BdMetadata(
        title: title,
        authors: authors,
        publisher: publisher,
        description: description,
        coverUrl: coverUrl,
        volumeNumber: volumeNumber,
      );
    } catch (_) {
      return null;
    }
  }

  /// Métadonnées via l'API Google Books (`books#volumes` / `volumeInfo`).
  Future<BdMetadata?> _fetchFromGoogleBooks(String isbn13) async {
    try {
      final uri = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn13',
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

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) return null;

      final items = decoded['items'];
      if (items is! List || items.isEmpty) return null;

      final first = items.first;
      if (first is! Map<String, dynamic>) return null;

      final volumeInfo = first['volumeInfo'];
      if (volumeInfo is! Map<String, dynamic>) return null;

      final title = (volumeInfo['title'] as String?)?.trim();
      if (title == null || title.isEmpty) return null;

      List<String>? authors;
      final rawAuthors = volumeInfo['authors'];
      if (rawAuthors is List) {
        final list = rawAuthors
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (list.isNotEmpty) authors = list;
      }

      final publisherRaw = (volumeInfo['publisher'] as String?)?.trim();
      final publisher =
          publisherRaw != null && publisherRaw.isNotEmpty ? publisherRaw : null;

      final publishedRaw = (volumeInfo['publishedDate'] as String?)?.trim();
      final publishedDate =
          publishedRaw != null && publishedRaw.isNotEmpty ? publishedRaw : null;

      String? description = (volumeInfo['description'] as String?)?.trim();
      if (description == null || description.isEmpty) {
        final searchInfo = first['searchInfo'];
        if (searchInfo is Map<String, dynamic>) {
          description = (searchInfo['textSnippet'] as String?)?.trim();
        }
      }
      if (description != null && description.isEmpty) description = null;
      if (description != null) description = _decodeHtmlEntities(description);

      String? coverUrl;
      final imageLinks = volumeInfo['imageLinks'];
      if (imageLinks is Map<String, dynamic>) {
        final thumb = imageLinks['thumbnail'] as String? ??
            imageLinks['smallThumbnail'] as String?;
        coverUrl = _httpsCoverUrl(thumb?.trim());
      }

      String? volumeNumber;
      final subtitle = (volumeInfo['subtitle'] as String?)?.trim();
      for (final candidate in [subtitle, title]) {
        if (candidate == null) continue;
        final match = _tomeRegex.firstMatch(candidate);
        if (match != null) {
          volumeNumber = match.group(1);
          break;
        }
      }

      String? seriesTitle;
      String? seriesBookIndex;
      final seriesInfo = volumeInfo['seriesInfo'];
      if (seriesInfo is Map<String, dynamic>) {
        final s = seriesInfo['series'];
        if (s is Map<String, dynamic>) {
          final st = s['title'];
          if (st != null && st.toString().trim().isNotEmpty) {
            seriesTitle = st.toString().trim();
          }
          final dn = s['displayNumber'] ?? seriesInfo['bookDisplayNumber'];
          if (dn != null && dn.toString().trim().isNotEmpty) {
            seriesBookIndex = dn.toString().trim();
          }
        } else if (s is String && s.trim().isNotEmpty) {
          seriesTitle = s.trim();
        }
      }
      if (volumeNumber == null &&
          seriesBookIndex != null &&
          seriesBookIndex.isNotEmpty) {
        final digits = RegExp(r'(\d+)').firstMatch(seriesBookIndex);
        if (digits != null) volumeNumber = digits.group(1);
      }

      return BdMetadata(
        title: title,
        authors: authors,
        publisher: publisher,
        publishedDate: publishedDate,
        description: description,
        coverUrl: coverUrl,
        volumeNumber: volumeNumber,
        seriesTitle: seriesTitle,
      );
    } catch (_) {
      return null;
    }
  }
}
