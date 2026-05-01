import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/bd_metadata.dart';

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
  /// Métadonnées via l’API Google Books (`books#volumes` / `volumeInfo`).
  Future<BdMetadata?> fetchByIsbn(String isbn13) async {
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

      final decoded = jsonDecode(response.body);
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
