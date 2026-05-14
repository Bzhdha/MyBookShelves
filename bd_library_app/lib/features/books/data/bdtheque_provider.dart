import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../../models/bd_metadata.dart';

final _tomeRegex = RegExp(r'Tome\s*(\d+)', caseSensitive: false);

class BdThequeProvider {
  Future<BdMetadata?> fetchByIsbn(String isbn13) async {
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
      if (title != null) { final m = _tomeRegex.firstMatch(title); if (m != null) volumeNumber = m.group(1); }

      List<String>? authors;
      final authorLinks = doc.querySelectorAll('a[href*="/auteur-"]');
      if (authorLinks.isNotEmpty) authors = authorLinks.map((a) => a.text.trim()).where((s) => s.isNotEmpty).toSet().toList();

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
        if (coverUrl != null && !coverUrl.startsWith('http')) coverUrl = 'https://www.bdtheque.com$coverUrl';
      }

      if (title == null || title.isEmpty) return null;
      return BdMetadata(title: title, authors: authors, publisher: publisher, description: description, coverUrl: coverUrl, volumeNumber: volumeNumber);
    } catch (_) {
      return null;
    }
  }
}
