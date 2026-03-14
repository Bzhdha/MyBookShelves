import '../../../models/bd_metadata.dart';

/// Interface commune pour les fournisseurs de métadonnées via API LLM (OpenAI, Claude, Mistral, Groq).
abstract class LlmMetadataProvider {
  bool get isConfigured;
  Future<BdMetadata?> fetchByIsbn(String isbn);
}

/// Parse un objet JSON renvoyé par un LLM en [BdMetadata]. Retourne null si titre manquant.
BdMetadata? parseLlmMetadataJson(Map<String, dynamic> meta) {
  String? title;
  if (meta['title'] != null && meta['title'].toString().trim().isNotEmpty) {
    title = meta['title'].toString().trim();
  }

  List<String>? authors;
  final rawAuthors = meta['authors'];
  if (rawAuthors is List) {
    authors = rawAuthors
        .map((e) => e?.toString().trim())
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
    if (authors.isEmpty) authors = null;
  }

  String? publisher;
  if (meta['publisher'] != null && meta['publisher'].toString().trim().isNotEmpty) {
    publisher = meta['publisher'].toString().trim();
  }

  String? publishedDate;
  if (meta['publishedDate'] != null && meta['publishedDate'].toString().trim().isNotEmpty) {
    publishedDate = meta['publishedDate'].toString().trim();
  }

  String? volumeNumber;
  if (meta['volumeNumber'] != null && meta['volumeNumber'].toString().trim().isNotEmpty) {
    volumeNumber = meta['volumeNumber'].toString().trim();
  }

  if (title == null || title.isEmpty) return null;

  return BdMetadata(
    title: title,
    authors: authors,
    publisher: publisher,
    publishedDate: publishedDate,
    volumeNumber: volumeNumber,
  );
}
