import 'package:http/http.dart' as http;
import 'google_books_provider.dart';
import 'bdtheque_provider.dart';
import 'open_library_provider.dart';

class CoverCandidate {
  final String url;
  final String source;
  const CoverCandidate({required this.url, required this.source});
}

class CoverSearchService {
  final GoogleBooksProvider _google;
  final BdThequeProvider _bdTheque;
  final OpenLibraryProvider _openLib;

  CoverSearchService({required GoogleBooksProvider google, required BdThequeProvider bdTheque, required OpenLibraryProvider openLib})
      : _google = google, _bdTheque = bdTheque, _openLib = openLib;

  Future<List<CoverCandidate>> searchByIsbn(String isbn) async {
    final found = await Future.wait([
      _olDirect(isbn),
      _googleCover(isbn),
      _bdthequeCover(isbn),
      _olApiCover(isbn),
    ]);
    final seen = <String>{};
    final res = <CoverCandidate>[];
    for (final c in found) {
      if (c != null && seen.add(c.url)) res.add(c);
    }
    return res;
  }

  Future<CoverCandidate?> _olDirect(String isbn) async {
    try {
      final url = 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg?default=false';
      final r = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 6));
      if (r.statusCode == 200) return CoverCandidate(url: url, source: 'Open Library');
      return null;
    } catch (_) { return null; }
  }

  Future<CoverCandidate?> _googleCover(String isbn) async {
    try {
      final meta = await _google.fetchByIsbn(isbn);
      if (meta?.coverUrl == null) return null;
      final url = meta!.coverUrl!.replaceAll('zoom=1', 'zoom=3').replaceAll('&edge=curl', '');
      return CoverCandidate(url: url, source: 'Google Books');
    } catch (_) { return null; }
  }

  Future<CoverCandidate?> _bdthequeCover(String isbn) async {
    try {
      final meta = await _bdTheque.fetchByIsbn(isbn);
      if (meta?.coverUrl == null) return null;
      return CoverCandidate(url: meta!.coverUrl!, source: 'BdThèque');
    } catch (_) { return null; }
  }

  Future<CoverCandidate?> _olApiCover(String isbn) async {
    try {
      final meta = await _openLib.fetchByIsbn(isbn);
      if (meta?.coverUrl == null) return null;
      return CoverCandidate(url: meta!.coverUrl!, source: 'Open Library (API)');
    } catch (_) { return null; }
  }
}
