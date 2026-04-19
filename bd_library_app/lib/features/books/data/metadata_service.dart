import '../../../core/app_logger.dart';
import '../../../models/bd_metadata.dart';
import 'bdtheque_provider.dart';
import 'llm_metadata_provider.dart';
import 'open_library_provider.dart';

class MetadataService {
  final OpenLibraryProvider openLibrary;
  final BdThequeProvider bdTheque;
  final List<LlmMetadataProvider> llmProviders;
  final AppLogger? logger;

  MetadataService({
    required this.openLibrary,
    required this.bdTheque,
    this.llmProviders = const [],
    this.logger,
  });

  /// Indique si au moins un fournisseur LLM a une clé API configurée.
  bool get hasAnyConfiguredLlm => llmProviders.any((p) => p.isConfigured);

  /// Recherche uniquement sur les sources Web (BdTheque, Open Library). Pas de LLM.
  Future<BdMetadata?> enrichFromIsbnWebOnly(String isbn13) async {
    logger?.log('MetadataService.enrichFromIsbnWebOnly', {'isbn': isbn13});
    final results = await Future.wait<BdMetadata?>([
      _safeFetchBdTheque(isbn13),
      _safeFetchOpenLibrary(isbn13),
    ]);
    return _mergeBdFirst(results[0], results[1]);
  }

  /// Lance une recherche via le premier LLM configuré avec le prompt utilisateur donné.
  /// Retourne la réponse brute et les métadonnées parsées (si le JSON est valide).
  Future<LlmPromptResult?> enrichFromCustomUserPrompt(String userPrompt) async {
    logger?.log('MetadataService.enrichFromCustomUserPrompt', {'promptLength': userPrompt.length});
    for (final provider in llmProviders) {
      if (!provider.isConfigured) continue;
      try {
        final result = await provider.fetchWithUserPrompt(userPrompt);
        if (result != null) return result;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<BdMetadata?> enrichFromIsbn(String isbn13) async {
    logger?.log('MetadataService.enrichFromIsbn', {'isbn': isbn13});
    final results = await Future.wait<BdMetadata?>([
      _safeFetchBdTheque(isbn13),
      _safeFetchOpenLibrary(isbn13),
    ]);

    BdMetadata? bdMeta = results[0];
    BdMetadata? olMeta = results[1];

    if (bdMeta == null && olMeta == null) {
      for (final provider in llmProviders) {
        if (!provider.isConfigured) continue;
        final meta = await _safeFetchLlm(provider, isbn13);
        if (meta != null) return meta;
      }
      return null;
    }

    return _mergeBdFirst(bdMeta, olMeta);
  }

  Future<BdMetadata?> _safeFetchLlm(LlmMetadataProvider provider, String isbn) async {
    logger?.log('MetadataService._safeFetchLlm', {'provider': provider.runtimeType.toString(), 'isbn': isbn});
    try {
      return await provider.fetchByIsbn(isbn);
    } catch (e) {
      logger?.log('MetadataService._safeFetchLlm.error', {'provider': provider.runtimeType.toString(), 'isbn': isbn, 'error': e.toString()});
      return null;
    }
  }

  Future<BdMetadata?> _safeFetchBdTheque(String isbn) async {
    logger?.log('MetadataService._safeFetchBdTheque', {'isbn': isbn});
    try {
      return await bdTheque.fetchByIsbn(isbn);
    } catch (e) {
      logger?.log('MetadataService._safeFetchBdTheque.error', {'isbn': isbn, 'error': e.toString()});
      return null;
    }
  }

  Future<BdMetadata?> _safeFetchOpenLibrary(String isbn) async {
    logger?.log('MetadataService._safeFetchOpenLibrary', {'isbn': isbn});
    try {
      return await openLibrary.fetchByIsbn(isbn);
    } catch (e) {
      logger?.log('MetadataService._safeFetchOpenLibrary.error', {'isbn': isbn, 'error': e.toString()});
      return null;
    }
  }

  BdMetadata _mergeBdFirst(
    BdMetadata? bd,
    BdMetadata? ol,
  ) {
    return BdMetadata(
      title: _pickString(bd?.title, ol?.title),

      authors: _pickAuthors(
        preferred: bd?.authors,
        fallback: ol?.authors,
      ),

      publisher: _pickString(bd?.publisher, ol?.publisher),

      publishedDate: _pickString(bd?.publishedDate, ol?.publishedDate),

      description: _pickString(bd?.description, ol?.description),

      coverUrl: _pickString(bd?.coverUrl, ol?.coverUrl),

      volumeNumber: _pickString(bd?.volumeNumber, ol?.volumeNumber),
    );
  }

  String? _pickString(String? preferred, String? fallback) {
    if (_isFilled(preferred)) return preferred!.trim();
    if (_isFilled(fallback)) return fallback!.trim();
    return null;
  }

  List<String>? _pickAuthors({
    List<String>? preferred,
    List<String>? fallback,
  }) {
    if (preferred != null && preferred.isNotEmpty) return preferred;
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return null;
  }

  bool _isFilled(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
