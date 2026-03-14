import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Télécharge une couverture (depuis coverUrl) et la stocke dans /documents/covers/.
class CoverCacheService {
  Future<Directory> coversDir() async {
    final doc = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(doc.path, 'covers'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Retourne le path local (ou null si échec).
  /// Le fichier est nommé "<bookId>.<ext>"
  Future<String?> downloadCoverToLocalPath({
    required String bookId,
    required String? coverUrl,
  }) async {
    if (coverUrl == null || coverUrl.trim().isEmpty) return null;

    try {
      final uri = Uri.tryParse(coverUrl);
      if (uri == null) return null;

      final res = await http.get(uri);
      if (res.statusCode != 200) return null;

      final bytes = res.bodyBytes;
      if (bytes.isEmpty) return null;

      String ext = '.jpg';
      final ct = (res.headers['content-type'] ?? '').toLowerCase();
      if (ct.contains('png')) ext = '.png';
      if (ct.contains('webp')) ext = '.webp';

      final dir = await coversDir();
      final file = File(p.join(dir.path, '$bookId$ext'));
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
