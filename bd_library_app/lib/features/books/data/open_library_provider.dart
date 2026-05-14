import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/app_logger.dart';
import '../../../models/bd_metadata.dart';

class OpenLibraryProvider {
  OpenLibraryProvider({this.logger});
  final AppLogger? logger;

  Future<BdMetadata?> fetchByIsbn(String isbn) async {
    try {
      final r = await http.get(
        Uri.parse('https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data'),
        headers: {'User-Agent': 'bd_library_app/1.0', 'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return null;
      final d = jsonDecode(utf8.decode(r.bodyBytes));
      if (d is! Map || d.isEmpty) return null;
      final book = d['ISBN:$isbn'];
      if (book is! Map) return null;

      final title = _ne(book['title'] as String?);
      if (title == null) return null;

      List<String>? authors;
      if (book['authors'] is List) {
        final l = (book['authors'] as List)
            .map((a) => a is Map ? _ne(a['name'] as String?) : null)
            .where((s) => s != null).cast<String>().toList();
        if (l.isNotEmpty) authors = l;
      }

      String? publisher;
      if (book['publishers'] is List && (book['publishers'] as List).isNotEmpty) {
        final p = (book['publishers'] as List).first;
        publisher = _ne(p is Map ? p['name'] as String? : p?.toString());
      }

      String? desc;
      final n = book['notes'];
      if (n is String) desc = _ne(n);
      else if (n is Map) desc = _ne(n['value'] as String?);

      String? cover;
      if (book['cover'] is Map) cover = _ne((book['cover']['large'] ?? book['cover']['medium'] ?? book['cover']['small']) as String?);

      String? vol;
      final m = RegExp(r'Tome\s*(\d+)', caseSensitive: false).firstMatch(title);
      if (m != null) vol = m.group(1);

      String? series;
      if (book['series'] is List && (book['series'] as List).isNotEmpty) series = _ne((book['series'] as List).first?.toString());

      return BdMetadata(
        title: title, authors: authors, publisher: publisher,
        publishedDate: _ne(book['publish_date'] as String?),
        description: desc, coverUrl: cover, volumeNumber: vol, seriesTitle: series,
      );
    } catch (e) {
      logger?.log('OpenLibraryProvider.error', {'isbn': isbn, 'error': e.toString()});
      return null;
    }
  }

  String? _ne(String? s) => (s?.trim().isEmpty ?? true) ? null : s!.trim();
}
