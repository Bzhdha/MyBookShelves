import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:rectangle_detector/rectangle_detector.dart';

import '../data/cover_cache_service.dart';
import '../data/cover_scan_service.dart';
import '../../settings/data/scan_settings_store.dart';

/// Résultat de la prise de photo couverture/dos : chemins des images recadrées (ou null si annulé).
class CoverPhotoResult {
  final String? coverPath;
  final String? backPath;

  CoverPhotoResult({this.coverPath, this.backPath});
}

/// Page de prise de photo de la couverture puis du dos du livre.
/// Détection des rectangles, encadrement vert (sélectionné) / rouge (autres), changement toutes les N secondes.
/// Clic = valider le rectangle, double-clic = annuler et revenir au scan ISBN.
class CoverPhotoPage extends StatefulWidget {
  const CoverPhotoPage({
    super.key,
    required this.bookId,
  });

  final String bookId;

  @override
  State<CoverPhotoPage> createState() => _CoverPhotoPageState();
}

class _CoverPhotoPageState extends State<CoverPhotoPage> {
  CameraController? _controller;
  List<RectangleFeature> _rectangles = [];
  int _selectedIndex = 0;
  int _imageWidth = 1;
  int _imageHeight = 1;
  bool _isProcessing = false;
  String? _coverPath;
  String? _error;
  Timer? _cycleTimer;
  Timer? _detectTimer;
  bool _phaseCover = true; // true = couverture, false = dos

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _detectTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Aucune caméra disponible');
        return;
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _error = null;
      });
      _startTimers();
    } catch (e) {
      setState(() => _error = 'Erreur caméra: $e');
    }
  }

  void _startTimers() {
    final store = context.read<ScanSettingsStore>();
    _cycleTimer?.cancel();
    _detectTimer?.cancel();
    _cycleTimer = Timer.periodic(store.rectangleSwitchDuration, (_) => _cycleSelection());
    _detectTimer = Timer.periodic(const Duration(seconds: 1), (_) => _runDetection());
  }

  void _cycleSelection() {
    if (!mounted || _rectangles.isEmpty) return;
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % _rectangles.length;
    });
  }

  Future<void> _runDetection() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    try {
      final xFile = await _controller!.takePicture();
      final bytes = await File(xFile.path).readAsBytes();
      final scanService = context.read<CoverScanService>();
      final list = await scanService.detectRectangles(bytes);
      if (!mounted) return;
      final decoded = _decodeImageSize(bytes);
      setState(() {
        _rectangles = list;
        if (_rectangles.isNotEmpty && _selectedIndex >= _rectangles.length) {
          _selectedIndex = 0;
        }
        if (decoded != null) {
          _imageWidth = decoded.$1;
          _imageHeight = decoded.$2;
        }
      });
    } catch (_) {
      // ignore
    }
  }

  (int, int)? _decodeImageSize(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      return decoded != null ? (decoded.width, decoded.height) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onTapConfirm() async {
    if (_controller == null || _isProcessing) return;
    if (_rectangles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun rectangle détecté. Cadrez le livre.')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final xFile = await _controller!.takePicture();
      final bytes = await File(xFile.path).readAsBytes();
      final scanService = context.read<CoverScanService>();
      final rect = _rectangles[_selectedIndex];
      final cropped = scanService.cropToRectangle(bytes, rect);
      if (cropped == null || !mounted) {
        setState(() => _isProcessing = false);
        return;
      }
      final coverCache = context.read<CoverCacheService>();
      final suffix = _phaseCover ? 'cover' : 'back';
      final savedPath = await coverCache.saveLocalImage(
        bookId: widget.bookId,
        imageBytes: cropped,
        suffix: suffix,
      );
      if (!mounted) return;
      if (_phaseCover) {
        _coverPath = savedPath;
        setState(() {
          _phaseCover = false;
          _rectangles = [];
          _selectedIndex = 0;
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couverture enregistrée. Prenez maintenant le dos du livre.')),
        );
      } else {
        setState(() => _isProcessing = false);
        Navigator.pop(context, CoverPhotoResult(coverPath: _coverPath, backPath: savedPath));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  void _onDoubleTapCancel() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Photo couverture / dos')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final phaseLabel = _phaseCover ? 'Couverture' : 'Dos du livre';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(phaseLabel),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreview(),
          _buildOverlay(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Clic = valider ce rectangle · Double-clic = annuler',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _isProcessing ? null : _onTapConfirm,
                      child: Text(_rectangles.isEmpty ? 'Aucun rectangle' : 'Valider ce rectangle'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onTapConfirm,
              onDoubleTap: _onDoubleTapCancel,
              child: CameraPreview(_controller!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlay() {
    if (_rectangles.isEmpty || _imageWidth <= 0 || _imageHeight <= 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final box = constraints.biggest;
        final ar = _controller!.value.aspectRatio;
        double w;
        double h;
        if (box.width / box.height > ar) {
          h = box.height;
          w = h * ar;
        } else {
          w = box.width;
          h = w / ar;
        }
        final left = (box.width - w) / 2;
        final top = (box.height - h) / 2;
        final scaleX = w / _imageWidth;
        final scaleY = h / _imageHeight;
        return CustomPaint(
          painter: _RectangleOverlayPainter(
            rectangles: _rectangles,
            selectedIndex: _selectedIndex,
            scaleX: scaleX,
            scaleY: scaleY,
            offsetX: left,
            offsetY: top,
          ),
          size: box,
        );
      },
    );
  }
}

class _RectangleOverlayPainter extends CustomPainter {
  _RectangleOverlayPainter({
    required this.rectangles,
    required this.selectedIndex,
    required this.scaleX,
    required this.scaleY,
    required this.offsetX,
    required this.offsetY,
  });

  final List<RectangleFeature> rectangles;
  final int selectedIndex;
  final double scaleX;
  final double scaleY;
  final double offsetX;
  final double offsetY;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < rectangles.length; i++) {
      final rect = rectangles[i];
      final isSelected = i == selectedIndex;
      final paint = Paint()
        ..color = isSelected ? Colors.green : Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      final path = Path()
        ..moveTo(offsetX + rect.topLeft.x * scaleX, offsetY + rect.topLeft.y * scaleY)
        ..lineTo(offsetX + rect.topRight.x * scaleX, offsetY + rect.topRight.y * scaleY)
        ..lineTo(offsetX + rect.bottomRight.x * scaleX, offsetY + rect.bottomRight.y * scaleY)
        ..lineTo(offsetX + rect.bottomLeft.x * scaleX, offsetY + rect.bottomLeft.y * scaleY)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RectangleOverlayPainter old) {
    return old.selectedIndex != selectedIndex ||
        old.rectangles.length != rectangles.length;
  }
}
