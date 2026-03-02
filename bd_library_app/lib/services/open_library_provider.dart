import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bd_metadata.dart';

class OpenLibraryProvider {
  Future<BdMetadata?> fetchByIsbn(String isbn13) async {
    final uri = Uri.parse(
      'https://openlibrary.org/api/books?bibkeys=ISBN:$isbn13&format=json&jscmd=data',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 4));
    if (response.statusCode != 200) return null;

    final Map<String, dynamic> jsonMap = json.decode(response.body);
    final data = jsonMap['ISBN:$isbn13'];
    if (data == null) return null;

    final title = data['title'] as String?;

    final authors = (data['authors'] as List?)
        ?.map((a) => a['name'] as String?)
        .whereType<String>()
        .toList();

    final publishers = (data['publishers'] as List?)
        ?.map((p) => p['name'] as String?)
        .whereType<String>()
        .toList();

    final publishDate = data['publish_date'] as String?;

    final coverUrl = (data['cover']?['large'] ??
        data['cover']?['medium'] ??
        data['cover']?['small']) as String?;

    return BdMetadata(
      title: title,
      authors: authors,
      publisher: (publishers != null && publishers.isNotEmpty) ? publishers.first : null,
      publishedDate: publishDate,
      coverUrl: coverUrl,
    );
  }
}
