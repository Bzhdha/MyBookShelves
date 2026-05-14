import '../../../core/app_logger.dart';
import '../../../models/bd_metadata.dart';
import 'bdtheque_provider.dart';
import 'llm_metadata_provider.dart';
import 'open_library_provider.dart';
import 'google_books_provider.dart';
import 'goodreads_provider.dart';
import 'amazon_provider.dart';

class MetadataService {
  final OpenLibraryProvider openLibrary;
  final BdThequeProvider bdTheque;
  final GoogleBooksProvider googleBooks;
  final GoodreadsProvider goodreads;
  final AmazonProvider amazon;
  final List<LlmMetadataProvider> llmProviders;
  final AppLogger? logger;

  MetadataService({
    required this.openLibrary,
    required this.bdTheque,
    required this.googleBooks,
    required this.goodreads,
    required this.amazon,
    this.llmProviders = const [],
    this.logger,
  });

  bool get hasAnyConfiguredLlm => llmProviders.any((p) => p.isConfigured);

  Future<BdMetadata?> enrichFromIsbnWebOnly(String isbn13) async {
    logger?.log('MetadataService.enrichFromIsbnWebOnly', {'isbn': isbn13});
    final results = await Future.wait<BdMetadata?>([
      _safe(bdTheque.fetchByIsbn, isbn13, 'bdTheque'),
      _safe(openLibrary.fetchByIsbn, isbn13, 'openLibrary'),
      _safe(googleBooks.fetchByIsbn, isbn13, 'googleBooks'),
      _safe(goodreads.fetchByIsbn, isbn13, 'goodreads'),
      _safe(amazon.fetchByIsbn, isbn13, 'amazon'),
    ]);
    return _mergeAll(results);
  }

  Future<LlmPromptResult?> enrichFromCustomUserPrompt(String userPrompt) async {
    logger?.log('MetadataService.enrichFromCustomUserPrompt', {'promptLength': userPrompt.length});
    for (final p in llmProviders) {
      if (!p.isConfigured) continue;
      try { final r = await p.fetchWithUserPrompt(userPrompt); if (r != null) return r; } catch (_) {}
    }
    return null;
  }

  Future<BdMetadata?> enrichFromIsbn(String isbn13) async {
    logger?.log('MetadataService.enrichFromIsbn', {'isbn': isbn13});
    final results = await Future.wait<BdMetadata?>([
      _safe(bdTheque.fetchByIsbn, isbn13, 'bdTheque'),
      _safe(openLibrary.fetchByIsbn, isbn13, 'openLibrary'),
      _safe(googleBooks.fetchByIsbn, isbn13, 'googleBooks'),
      _safe(goodreads.fetchByIsbn, isbn13, 'goodreads'),
      _safe(amazon.fetchByIsbn, isbn13, 'amazon'),
    ]);
    final merged = _mergeAll(results);
    if (merged == null) {
      for (final p in llmProviders) {
        if (!p.isConfigured) continue;
        try { final m = await p.fetchByIsbn(isbn13); if (m != null) return m; } catch (_) {}
      }
      return null;
    }
    return merged;
  }

  Future<BdMetadata?> _safe(Future<BdMetadata?> Function(String) fn, String isbn, String name) async {
    try { return await fn(isbn); }
    catch (e) { logger?.log('MetadataService.$name.error', {'isbn': isbn, 'error': e.toString()}); return null; }
  }

  BdMetadata? _mergeAll(List<BdMetadata?> results) {
    if (results.every((r) => r == null)) return null;
    return BdMetadata(
      title: _pick(results.map((r) => r?.title)),
      authors: _pickAuthors(results.map((r) => r?.authors)),
      publisher: _pick(results.map((r) => r?.publisher)),
      publishedDate: _pick(results.map((r) => r?.publishedDate)),
      description: _pick(results.map((r) => r?.description)),
      coverUrl: _pick(results.map((r) => r?.coverUrl)),
      volumeNumber: _pick(results.map((r) => r?.volumeNumber)),
      seriesTitle: _pick(results.map((r) => r?.seriesTitle)),
    );
  }

  String? _pick(Iterable<String?> values) {
    for (final v in values) { if (v != null && v.trim().isNotEmpty) return v.trim(); }
    return null;
  }

  List<String>? _pickAuthors(Iterable<List<String>?> values) {
    for (final v in values) { if (v != null && v.isNotEmpty) return v; }
    return null;
  }
}
