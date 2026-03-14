import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Télécharge une couverture (depuis coverUrl) et la stocke dans /documents/covers/.
/// Gère aussi la sauvegarde des photos prises au scan (couverture et dos).
class CoverCacheService {
  Future<Directory> coversDir() async {
    final doc = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(doc.path, 'covers'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Sauvegarde une image locale (bytes JPEG) pour un livre.
  /// [suffix] : 'cover' => couverture (fichier bookId.jpg), 'back' => dos (bookId_back.jpg).
  /// Retourne le chemin du fichier.
  Future<String> saveLocalImage({
    required String bookId,
    required List<int> imageBytes,
    String suffix = 'cover',
  }) async {
    final dir = await coversDir();
    final name = suffix == 'cover' ? bookId : '${bookId}_back';
    final path = p.join(dir.path, '$name.jpg');
    await File(path).writeAsBytes(imageBytes, flush: true);
    return path;
  }

  /// Retourne le chemin attendu pour la photo du dos (sans vérifier l'existence).
  Future<String> backCoverPathForBook(String bookId) async {
    final dir = await coversDir();
    return p.join(dir.path, '${bookId}_back.jpg');
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
