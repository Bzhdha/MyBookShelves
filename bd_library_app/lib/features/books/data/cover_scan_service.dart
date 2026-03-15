import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:rectangle_detector/rectangle_detector.dart';

/// Détection de rectangles dans une image et recadrage (bounding box + rectification optionnelle).
class CoverScanService {
  /// Détecte tous les rectangles dans l'image (bytes JPEG/PNG).
  Future<List<RectangleFeature>> detectRectangles(Uint8List imageBytes) async {
    try {
      final list = await RectangleDetector.detectAllRectangles(imageBytes);
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Recadre l'image sur le rectangle sélectionné (bounding box des 4 coins).
  /// Retourne les bytes JPEG de l'image recadrée, ou null en cas d'erreur.
  Uint8List? cropToRectangle(Uint8List imageBytes, RectangleFeature rect) {
    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) return null;

      final tlx = rect.topLeft.x.toInt().clamp(0, decoded.width - 1);
      final tly = rect.topLeft.y.toInt().clamp(0, decoded.height - 1);
      final trx = rect.topRight.x.toInt().clamp(0, decoded.width);
      final try_ = rect.topRight.y.toInt().clamp(0, decoded.height);
      final blx = rect.bottomLeft.x.toInt().clamp(0, decoded.width);
      final bly = rect.bottomLeft.y.toInt().clamp(0, decoded.height);
      final brx = rect.bottomRight.x.toInt().clamp(0, decoded.width);
      final bry = rect.bottomRight.y.toInt().clamp(0, decoded.height);

      final minX = [tlx, trx, blx, brx].reduce((a, b) => a < b ? a : b);
      final maxX = [tlx, trx, blx, brx].reduce((a, b) => a > b ? a : b);
      final minY = [tly, try_, bly, bry].reduce((a, b) => a < b ? a : b);
      final maxY = [tly, try_, bly, bry].reduce((a, b) => a > b ? a : b);

      var w = maxX - minX;
      var h = maxY - minY;
      if (w <= 0 || h <= 0) return null;
      if (minX + w > decoded.width) w = decoded.width - minX;
      if (minY + h > decoded.height) h = decoded.height - minY;
      if (w <= 0 || h <= 0) return null;

      final cropped = img.copyCrop(decoded, x: minX, y: minY, width: w, height: h);
      return Uint8List.fromList(img.encodeJpg(cropped, quality: 90));
    } catch (_) {
      return null;
    }
  }

  /// Recadre l'image sur un rectangle défini en pixels (pour sélection manuelle).
  Uint8List? cropToRect(
    Uint8List imageBytes, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) return null;
      final x0 = x.clamp(0, decoded.width - 1);
      final y0 = y.clamp(0, decoded.height - 1);
      var w = width.clamp(1, decoded.width - x0);
      var h = height.clamp(1, decoded.height - y0);
      if (x0 + w > decoded.width) w = decoded.width - x0;
      if (y0 + h > decoded.height) h = decoded.height - y0;
      if (w <= 0 || h <= 0) return null;
      final cropped = img.copyCrop(decoded, x: x0, y: y0, width: w, height: h);
      return Uint8List.fromList(img.encodeJpg(cropped, quality: 90));
    } catch (_) {
      return null;
    }
  }
}
