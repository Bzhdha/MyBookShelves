import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../../core/app_logger.dart';
import '../../../models/bd_metadata.dart';

class OpenLibraryProvider {
  OpenLibraryProvider({this.logger});

  final AppLogger? logger;

  Future<BdMetadata?> fetchByIsbn(String isbn13) async {
    try {
      final uri = Uri.parse(
        'https://isbndb.com/book/$isbn13',
      );

      final response = await http.get(uri, headers: {'User-Agent': 'bd_library_app/1.0', 'Accept': 'text/html,application/xhtml+xml'}).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        logger?.log('OpenLibraryProvider.fetchByIsbn', {'isbn': isbn13, 'error': 'HTTP ${response.statusCode}'});
        return null;
      }

      final doc = html_parser.parse(utf8.decode(response.bodyBytes));

      // Helper: récupère le <td> (texte) à partir d'un label de <th>
      String? tdTextFor(String thLabel) {
        final thList = doc.querySelectorAll('table th');
        for (final th in thList) {
          if (th.text.trim().toLowerCase() == thLabel.toLowerCase()) {
            final td = th.parent?.querySelector('td');
            final text = td?.text.trim();
            if (text != null && text.isNotEmpty) return text;
          }
        }
        return null;
      }

      // Title (priorité H1)
      final h1Title = doc.querySelector('h1.book-title')?.text.trim();
      final fullTitle = h1Title?.isNotEmpty == true
          ? h1Title
          : tdTextFor('Full Title:');

      // Publisher / Publish Date
      final publisher = tdTextFor('Publisher:');
      final publishDate = tdTextFor('Publish Date:');
      final seriesTitle = tdTextFor('Series:');

      // Authors: on préfère prendre le texte des <a> dans le <td>
      List<String>? authors;
      final thAuthors = doc
          .querySelectorAll('table th')
          .where((th) => th.text.trim().toLowerCase() == 'authors:')
          .cast<dynamic>()
          .toList();

      if (thAuthors.isNotEmpty) {
        final th = thAuthors.first;
        final td = th.parent?.querySelector('td');
        final aNames = td
            ?.querySelectorAll('a')
            .map((a) => a.text.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        if (aNames != null && aNames.isNotEmpty) {
          authors = aNames;
        } else {
          // fallback: texte brut du td (au cas où pas de <a>)
          final raw = td?.text.trim();
          if (raw != null && raw.isNotEmpty) {
            authors = [raw];
          }
        }
      }

      // Si au moins un champ est présent, on retourne un BdMetadata
      if ((fullTitle == null || fullTitle.isEmpty) &&
          (publisher == null || publisher.isEmpty) &&
          (publishDate == null || publishDate.isEmpty) &&
          (authors == null || authors.isEmpty)) {
        return null;
      }

      final coverUrl = doc.querySelector('.artwork object')?.attributes['data'];

      // Extraction du numéro de tome depuis le titre (ex: "Knight Club, Tome 1" ou "Volume 2")
      String? volumeNumber;
      if (fullTitle != null && fullTitle.isNotEmpty) {
        final tomeMatch = RegExp(r'Tome\s*(\d+)', caseSensitive: false).firstMatch(fullTitle);
        final volMatch = tomeMatch ?? RegExp(r'Volume\s*(\d+)', caseSensitive: false).firstMatch(fullTitle);
        if (volMatch != null) volumeNumber = volMatch.group(1);
      }

      return BdMetadata(
        title: fullTitle,
        authors: authors,
        publisher: publisher,
        publishedDate: publishDate,
        coverUrl: coverUrl,
        volumeNumber: volumeNumber,
        seriesTitle: seriesTitle?.trim().isNotEmpty == true ? seriesTitle!.trim() : null,
      );
    } catch (e) {
      logger?.log('OpenLibraryProvider.fetchByIsbn', {'isbn': isbn13, 'error': e.toString()});
      return null;
    }
  }
}
