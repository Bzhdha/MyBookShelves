import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../data/cover_cache_service.dart';
import '../data/cover_scan_service.dart';

/// Résultat de la prise de photo couverture/dos : chemins des images recadrées (ou null si annulé).
class CoverPhotoResult {
  final String? coverPath;
  final String? backPath;

  CoverPhotoResult({this.coverPath, this.backPath});
}

/// Page de prise de photo de la couverture puis du dos du livre.
/// Après chaque prise, l'utilisateur trace un cadre (bords déplaçables) pour recadrer, puis valide.
/// Si [onlySuffix] est 'cover' ou 'back', une seule photo est prise puis retournée.
///
/// Si [initialImagePath] est renseigné (fichier image local existant), l'écran de recadrage
/// s'ouvre directement sur cette image (ex. recadrer à nouveau une couverture déjà enregistrée).
/// « Reprendre » permet alors de passer à la caméra pour une nouvelle photo.
class CoverPhotoPage extends StatefulWidget {
  const CoverPhotoPage({
    super.key,
    required this.bookId,
    this.onlySuffix,
    this.initialImagePath,
  });

  final String bookId;
  /// 'cover' = uniquement couverture, 'back' = uniquement dos. Null = couverture puis dos.
  final String? onlySuffix;
  /// Image locale à recadrer sans reprendre de photo (typiquement couverture ou dos actuel).
  final String? initialImagePath;

  @override
  State<CoverPhotoPage> createState() => _CoverPhotoPageState();
}

class _CoverPhotoPageState extends State<CoverPhotoPage> {
  CameraController? _controller;
  bool _isProcessing = false;
  bool _torchOn = false;
  String? _error;
  late bool _phaseCover;

  /// Phase "recadrage" : image capturée (bytes) et cadre normalisé 0-1 (left, top, right, bottom).
  Uint8List? _capturedImage;
  int _imageWidth = 1;
  int _imageHeight = 1;
  Rect _cropRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);
  String? _coverPath;
  bool _loadingExisting = false;

  @override
  void initState() {
    super.initState();
    _phaseCover = widget.onlySuffix != 'back';
    final initial = widget.initialImagePath?.trim();
    if (initial != null && initial.isNotEmpty) {
      unawaited(_loadExistingImageForCrop(initial));
    } else {
      _initCamera();
    }
  }

  @override
  void dispose() {
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      unawaited(c.setFlashMode(FlashMode.off));
    }
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadExistingImageForCrop(String path) async {
    if (!mounted) return;
    setState(() {
      _loadingExisting = true;
      _error = null;
    });
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw StateError('Fichier introuvable');
      }
      final bytes = await file.readAsBytes();
      final decoded = _decodeImageSize(bytes);
      if (!mounted) return;
      setState(() {
        _loadingExisting = false;
        _capturedImage = bytes;
        _imageWidth = decoded?.$1 ?? 1;
        _imageHeight = decoded?.$2 ?? 1;
        _cropRect = const Rect.fromLTWH(0, 0, 1, 1);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingExisting = false);
      await _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Aucune caméra disponible');
        return;
      }
      CameraDescription selected = cameras.first;
      for (final c in cameras) {
        if (c.lensDirection == CameraLensDirection.back) {
          selected = c;
          break;
        }
      }
      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _torchOn = false;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Erreur caméra: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final xFile = await _controller!.takePicture();
      final bytes = await File(xFile.path).readAsBytes();
      final decoded = _decodeImageSize(bytes);
      if (_torchOn && _controller!.value.isInitialized) {
        try {
          await _controller!.setFlashMode(FlashMode.off);
        } catch (_) {}
        _torchOn = false;
      }
      if (!mounted) return;
      setState(() {
        _capturedImage = bytes;
        _imageWidth = decoded?.$1 ?? 1;
        _imageHeight = decoded?.$2 ?? 1;
        _cropRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
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

  void _onCropRectUpdate(Offset normalizedDelta, int corner) {
    setState(() {
      double left = _cropRect.left;
      double top = _cropRect.top;
      double right = _cropRect.right;
      double bottom = _cropRect.bottom;
      const minSize = 0.08;
      if (corner == 0) {
        left = (left + normalizedDelta.dx).clamp(0.0, right - minSize);
        top = (top + normalizedDelta.dy).clamp(0.0, bottom - minSize);
      } else if (corner == 1) {
        right = (right + normalizedDelta.dx).clamp(left + minSize, 1.0);
        top = (top + normalizedDelta.dy).clamp(0.0, bottom - minSize);
      } else if (corner == 2) {
        right = (right + normalizedDelta.dx).clamp(left + minSize, 1.0);
        bottom = (bottom + normalizedDelta.dy).clamp(top + minSize, 1.0);
      } else {
        left = (left + normalizedDelta.dx).clamp(0.0, right - minSize);
        bottom = (bottom + normalizedDelta.dy).clamp(top + minSize, 1.0);
      }
      _cropRect = Rect.fromLTRB(left, top, right, bottom);
    });
  }

  Future<void> _confirmCrop() async {
    if (_capturedImage == null || _imageWidth <= 0 || _imageHeight <= 0) return;
    setState(() => _isProcessing = true);
    try {
      final scanService = context.read<CoverScanService>();
      final x = (_cropRect.left * _imageWidth).round().clamp(0, _imageWidth - 1);
      final y = (_cropRect.top * _imageHeight).round().clamp(0, _imageHeight - 1);
      final w = ((_cropRect.right - _cropRect.left) * _imageWidth).round().clamp(1, _imageWidth - x);
      final h = ((_cropRect.bottom - _cropRect.top) * _imageHeight).round().clamp(1, _imageHeight - y);
      final cropped = scanService.cropToRect(_capturedImage!, x: x, y: y, width: w, height: h);
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
      final onlyOne = widget.onlySuffix != null;
      if (_phaseCover) {
        _coverPath = savedPath;
        if (onlyOne) {
          setState(() => _isProcessing = false);
          Navigator.pop(context, CoverPhotoResult(coverPath: savedPath, backPath: null));
          return;
        }
        setState(() {
          _phaseCover = false;
          _capturedImage = null;
          _isProcessing = false;
        });
        _showTopPhaseBanner(
          'Couverture enregistrée. Prenez maintenant le dos du livre.',
        );
      } else {
        setState(() => _isProcessing = false);
        if (onlyOne) {
          Navigator.pop(context, CoverPhotoResult(coverPath: null, backPath: savedPath));
        } else {
          Navigator.pop(context, CoverPhotoResult(coverPath: _coverPath, backPath: savedPath));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  void _cancelCrop() {
    setState(() {
      _capturedImage = null;
    });
    final needCamera = _controller == null || !_controller!.value.isInitialized;
    if (needCamera) {
      unawaited(_initCamera());
    }
  }

  /// Bannière sous l’AppBar (haut de l’écran), pour ne pas masquer le bouton « Prendre la photo » en bas.
  void _showTopPhaseBanner(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => messenger.hideCurrentMaterialBanner(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    unawaited(Future<void>.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      messenger.hideCurrentMaterialBanner();
    }));
  }

  Future<void> _toggleTorch() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _capturedImage != null) return;
    try {
      if (_torchOn) {
        await c.setFlashMode(FlashMode.off);
        if (mounted) setState(() => _torchOn = false);
      } else {
        await c.setFlashMode(FlashMode.torch);
        if (mounted) setState(() => _torchOn = true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flash non disponible sur cet appareil')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Photo couverture / dos')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_capturedImage != null) {
      return _buildCropScreen();
    }
    if (_loadingExisting) {
      final phaseLabel = _phaseCover ? 'Couverture' : 'Dos du livre';
      return Scaffold(
        appBar: AppBar(title: Text(phaseLabel)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildCameraScreen();
  }

  Widget _buildCameraScreen() {
    final phaseLabel = _phaseCover ? 'Couverture' : 'Dos du livre';
    return Scaffold(
      appBar: AppBar(
        title: Text(phaseLabel),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _isProcessing ? null : _toggleTorch,
            tooltip: 'Flash',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isProcessing ? null : () => Navigator.pop(context),
            tooltip: 'Sortir',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 1,
                height: _controller!.value.previewSize?.width ?? 1,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _isProcessing ? null : _takePicture,
                  child: _isProcessing
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Prendre la photo'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_phaseCover ? 'Recadrer la couverture' : 'Recadrer le dos'),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _cancelCrop,
            child: const Text('Reprendre'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildImageWithCropOverlay()),
            Material(
              elevation: 6,
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _isProcessing ? null : _confirmCrop,
                  child: _isProcessing
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Valider le recadrage'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithCropOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _CropOverlay(
          imageBytes: _capturedImage!,
          imageWidth: _imageWidth,
          imageHeight: _imageHeight,
          cropRect: _cropRect,
          onCropUpdate: _onCropRectUpdate,
          isProcessing: _isProcessing,
        );
      },
    );
  }
}

/// Affiche l'image et un cadre de recadrage avec 4 poignées déplaçables.
class _CropOverlay extends StatefulWidget {
  const _CropOverlay({
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.cropRect,
    required this.onCropUpdate,
    required this.isProcessing,
  });

  final Uint8List imageBytes;
  final int imageWidth;
  final int imageHeight;
  final Rect cropRect;
  final void Function(Offset normalizedDelta, int corner) onCropUpdate;
  final bool isProcessing;

  @override
  State<_CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<_CropOverlay> {
  int? _draggingCorner;
  Offset? _lastLocal;
  Rect _imageRect = Rect.zero;

  void _onPanStart(DragStartDetails details, int corner) {
    if (widget.isProcessing) return;
    setState(() {
      _draggingCorner = corner;
      _lastLocal = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggingCorner == null) return;
    if (_imageRect.width <= 0 || _imageRect.height <= 0) return;
    final cur = details.localPosition;
    final prev = _lastLocal ?? cur;
    final dx = (cur.dx - prev.dx) / _imageRect.width;
    final dy = (cur.dy - prev.dy) / _imageRect.height;
    widget.onCropUpdate(Offset(dx, dy), _draggingCorner!);
    setState(() => _lastLocal = cur);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _draggingCorner = null;
      _lastLocal = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageAspect = widget.imageWidth / widget.imageHeight;
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = constraints.biggest;
        double w, h;
        if (box.width / box.height > imageAspect) {
          h = box.height;
          w = h * imageAspect;
        } else {
          w = box.width;
          h = w / imageAspect;
        }
        final offsetX = (box.width - w) / 2;
        final offsetY = (box.height - h) / 2;
        _imageRect = Rect.fromLTWH(offsetX, offsetY, w, h);

        final left = offsetX + widget.cropRect.left * w;
        final top = offsetY + widget.cropRect.top * h;
        final right = offsetX + widget.cropRect.right * w;
        final bottom = offsetY + widget.cropRect.bottom * h;

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.memory(
                  widget.imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (d) => _onPanStart(d, 0),
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: _CropFramePainter(
                  cropRect: Rect.fromLTRB(left, top, right, bottom),
                  handleRadius: 24,
                ),
                size: box,
              ),
            ),
            _buildHandle(Offset(left, top), 0),
            _buildHandle(Offset(right, top), 1),
            _buildHandle(Offset(right, bottom), 2),
            _buildHandle(Offset(left, bottom), 3),
          ],
        );
      },
    );
  }

  Widget _buildHandle(Offset position, int corner) {
    return Positioned(
      left: position.dx - 24,
      top: position.dy - 24,
      width: 48,
      height: 48,
      child: GestureDetector(
        onPanStart: (d) => _onPanStart(d, corner),
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _CropFramePainter extends CustomPainter {
  _CropFramePainter({required this.cropRect, this.handleRadius = 24});

  final Rect cropRect;
  final double handleRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cropPath = Path()..addRect(cropRect);
    final mask = Path.combine(PathOperation.difference, path, cropPath);
    canvas.drawPath(mask, fill);

    final stroke = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(cropRect, stroke);
  }

  @override
  bool shouldRepaint(covariant _CropFramePainter old) =>
      old.cropRect != cropRect;
}
