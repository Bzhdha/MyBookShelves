import '../models/bd_metadata.dart';
import 'open_library_provider.dart';

class MetadataService {
  final OpenLibraryProvider openLibrary;

  MetadataService({required this.openLibrary});

  Future<BdMetadata?> enrichFromIsbn(String isbn13) async {
    return openLibrary.fetchByIsbn(isbn13);
  }
}
