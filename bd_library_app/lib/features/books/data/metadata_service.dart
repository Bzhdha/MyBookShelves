import '../../../models/bd_metadata.dart';
import 'bdtheque_provider.dart';
import 'llm_metadata_provider.dart';
import 'open_library_provider.dart';

class MetadataService {
  final OpenLibraryProvider openLibrary;
  final BdThequeProvider bdTheque;
  final List<LlmMetadataProvider> llmProviders;

  MetadataService({
    required this.openLibrary,
    required this.bdTheque,
    this.llmProviders = const [],
  });

  Future<BdMetadata?> enrichFromIsbn(String isbn13) async {
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
    try {
      return await provider.fetchByIsbn(isbn);
    } catch (_) {
      return null;
    }
  }

  Future<BdMetadata?> _safeFetchBdTheque(String isbn) async {
    try {
      return await bdTheque.fetchByIsbn(isbn);
    } catch (_) {
      return null;
    }
  }

  Future<BdMetadata?> _safeFetchOpenLibrary(String isbn) async {
    try {
      return await openLibrary.fetchByIsbn(isbn);
    } catch (_) {
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
