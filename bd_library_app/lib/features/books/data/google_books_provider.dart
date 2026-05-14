import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../../core/app_logger.dart';
import '../../../models/bd_metadata.dart';

final _tomeRe = RegExp(r'Tome\s*(\d+)', caseSensitive: false);
String? _https(String? u) => u == null ? null : u.startsWith('http://') ? 'https://${u.substring(7)}' : u;
String _deHtml(String t) => html_parser.parseFragment(t).text ?? t;

class GoogleBooksProvider {
  GoogleBooksProvider({this.logger});
  final AppLogger? logger;

  Future<BdMetadata?> fetchByIsbn(String isbn) async {
    try {
      final r = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'),
        headers: {'User-Agent': 'bd_library_app/1.0', 'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      if (r.statusCode != 200) return null;
      final d = jsonDecode(utf8.decode(r.bodyBytes));
      if (d is! Map || d['items'] is! List || (d['items'] as List).isEmpty) return null;
      final item = (d['items'] as List).first as Map<String, dynamic>;
      final vi = item['volumeInfo'];
      if (vi is! Map) return null;
      final title = _ne(vi['title'] as String?);
      if (title == null) return null;

      List<String>? authors;
      if (vi['authors'] is List) {
        final l = (vi['authors'] as List).whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        if (l.isNotEmpty) authors = l;
      }

      String? desc = _ne(vi['description'] as String?);
      if (desc == null && item['searchInfo'] is Map) desc = _ne(item['searchInfo']['textSnippet'] as String?);
      if (desc != null) desc = _deHtml(desc);

      String? cover;
      if (vi['imageLinks'] is Map) cover = _https(_ne((vi['imageLinks']['thumbnail'] ?? vi['imageLinks']['smallThumbnail']) as String?));

      String? vol;
      for (final c in [_ne(vi['subtitle'] as String?), title]) {
        if (c == null) continue;
        final m = _tomeRe.firstMatch(c);
        if (m != null) { vol = m.group(1); break; }
      }

      String? series;
      final si = vi['seriesInfo'];
      if (si is Map) {
        final s = si['series'];
        if (s is Map) {
          series = _ne(s['title'] as String?);
          if (vol == null) {
            final dn = _ne((s['displayNumber'] ?? si['bookDisplayNumber'])?.toString());
            if (dn != null) { final m = RegExp(r'(\d+)').firstMatch(dn); if (m != null) vol = m.group(1); }
          }
        } else if (s is String) series = _ne(s);
      }

      return BdMetadata(
        title: title, authors: authors,
        publisher: _ne(vi['publisher'] as String?), publishedDate: _ne(vi['publishedDate'] as String?),
        description: desc, coverUrl: cover, volumeNumber: vol, seriesTitle: series,
      );
    } catch (e) {
      logger?.log('GoogleBooksProvider.error', {'isbn': isbn, 'error': e.toString()});
      return null;
    }
  }

  String? _ne(String? s) => (s?.trim().isEmpty ?? true) ? null : s!.trim();
}
