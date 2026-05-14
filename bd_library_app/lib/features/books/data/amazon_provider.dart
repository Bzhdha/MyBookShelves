import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../../core/app_logger.dart';
import '../../../models/bd_metadata.dart';

class AmazonProvider {
  AmazonProvider({this.logger});
  final AppLogger? logger;

  static const _hdrs = {
    'User-Agent': 'Mozilla/5.0 (compatible; bd_library_app/1.0)',
    'Accept': 'text/html',
    'Accept-Language': 'fr-FR,fr;q=0.9',
  };

  Future<BdMetadata?> fetchByIsbn(String isbn) async {
    try {
      final sr = await http.get(Uri.parse('https://www.amazon.fr/s?k=$isbn&i=stripbooks'), headers: _hdrs).timeout(const Duration(seconds: 8));
      if (sr.statusCode != 200) return null;
      final sd = html_parser.parse(utf8.decode(sr.bodyBytes));

      final asin = sd.querySelector('[data-asin]')?.attributes['data-asin'];
      if (asin == null || asin.isEmpty) return _fromSearch(sd);

      final pr = await http.get(Uri.parse('https://www.amazon.fr/dp/$asin'), headers: _hdrs).timeout(const Duration(seconds: 8));
      if (pr.statusCode != 200) return null;
      final doc = html_parser.parse(utf8.decode(pr.bodyBytes));

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

      title ??= _ne(doc.querySelector('#productTitle')?.text);
      cover ??= _ne(doc.querySelector('#imgTagWrapperId img')?.attributes['src'] ?? doc.querySelector('#ebooksImgBlkFront')?.attributes['src']);
      desc ??= _ne(doc.querySelector('#bookDescription_feature_div p')?.text ?? doc.querySelector('#feature-bullets')?.text);

      if (title == null) return null;
      return BdMetadata(title: title, authors: authors, coverUrl: cover, description: desc);
    } catch (e) {
      logger?.log('AmazonProvider.error', {'isbn': isbn, 'error': e.toString()});
      return null;
    }
  }

  BdMetadata? _fromSearch(dynamic doc) {
    final title = _ne(doc.querySelector('h2 span.a-text-normal')?.text);
    if (title == null) return null;
    return BdMetadata(title: title, coverUrl: _ne(doc.querySelector('.s-image')?.attributes['src']));
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
