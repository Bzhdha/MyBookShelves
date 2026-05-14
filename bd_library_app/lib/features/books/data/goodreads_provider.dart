import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../../core/app_logger.dart';
import '../../../models/bd_metadata.dart';

class GoodreadsProvider {
  GoodreadsProvider({this.logger});
  final AppLogger? logger;

  Future<BdMetadata?> fetchByIsbn(String isbn) async {
    try {
      final r = await http.get(
        Uri.parse('https://www.goodreads.com/book/isbn/$isbn'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; bd_library_app/1.0)',
          'Accept': 'text/html',
          'Accept-Language': 'fr-FR,fr;q=0.9',
        },
      ).timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return null;
      final doc = html_parser.parse(utf8.decode(r.bodyBytes));

      String? title, cover, desc;
      List<String>? authors;

      for (final s in doc.querySelectorAll('script[type="application/ld+json"]')) {
        try {
          final j = jsonDecode(s.text);
          final data = _findBook(j);
          if (data != null) {
            title = _ne(data['name'] as String?);
            cover = _ne(data['image'] as String?);
            desc = _ne(data['description'] as String?);
            authors = _extractAuthors(data['author']);
            break;
          }
        } catch (_) {}
      }

      title ??= _ne(doc.querySelector('meta[property="og:title"]')?.attributes['content']);
      cover ??= _ne(doc.querySelector('meta[property="og:image"]')?.attributes['content']);
      desc ??= _ne(doc.querySelector('meta[property="og:description"]')?.attributes['content']);

      if (title == null) return null;
      return BdMetadata(title: title, authors: authors, coverUrl: cover, description: desc);
    } catch (e) {
      logger?.log('GoodreadsProvider.error', {'isbn': isbn, 'error': e.toString()});
      return null;
    }
  }

  Map<String, dynamic>? _findBook(dynamic j) {
    if (j is Map && j['@type'] == 'Book') return j as Map<String, dynamic>;
    if (j is List) { for (final e in j) { final r = _findBook(e); if (r != null) return r; } }
    return null;
  }

  List<String>? _extractAuthors(dynamic a) {
    if (a is Map) { final n = _ne(a['name'] as String?); return n != null ? [n] : null; }
    if (a is List) {
      final l = a.map((e) => e is Map ? _ne(e['name'] as String?) : _ne(e?.toString())).where((s) => s != null).cast<String>().toList();
      return l.isNotEmpty ? l : null;
    }
    return null;
  }

  String? _ne(String? s) => (s?.trim().isEmpty ?? true) ? null : s!.trim();
}
