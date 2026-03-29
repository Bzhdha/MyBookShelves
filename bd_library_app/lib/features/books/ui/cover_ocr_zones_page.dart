import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../domain/book_service.dart';

/// Indique si la reconnaissance OCR (ML Kit) est disponible sur cette plateforme.
bool coverOcrSupportedPlatform() {
  if (kIsWeb) return false;
  try {
    return Platform.isAndroid || Platform.isIOS;
  } catch (_) {
    return false;
  }
}

class _ImageLayout {
  const _ImageLayout({
    required this.scale,
    required this.displayed,
    required this.offset,
  });

  final double scale;
  final Size displayed;
  final Offset offset;
}

_ImageLayout _computeLayout(Size maxBox, Size imageSize) {
  final s = math.min(
    maxBox.width / imageSize.width,
    maxBox.height / imageSize.height,
  );
  final disp = Size(imageSize.width * s, imageSize.height * s);
  final ox = (maxBox.width - disp.width) / 2;
  final oy = (maxBox.height - disp.height) / 2;
  return _ImageLayout(scale: s, displayed: disp, offset: Offset(ox, oy));
}

Offset _toImageSpace(Offset localInImageWidget, _ImageLayout layout) {
  return Offset(localInImageWidget.dx / layout.scale, localInImageWidget.dy / layout.scale);
}

/// Reconnaissance du texte sur une image de couverture, puis sélection dans l'ordre
/// du titre, de l'auteur et de l'éditeur en touchant les zones détectées.
class CoverOcrZonesPage extends StatefulWidget {
  const CoverOcrZonesPage({
    super.key,
    required this.imagePath,
    required this.bookId,
  });

  final String imagePath;
  final String bookId;

  @override
  State<CoverOcrZonesPage> createState() => _CoverOcrZonesPageState();
}

class _CoverOcrZonesPageState extends State<CoverOcrZonesPage> {
  int? _imageW;
  int? _imageH;
  String? _loadError;
  String? _ocrError;
  bool _ocrBusy = true;

  List<TextLine> _lines = [];
  int _step = 0;
  final List<int?> _pickedLineIndex = [null, null, null];

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (!mounted) return;
      if (decoded == null) {
        setState(() {
          _loadError = 'Image illisible';
          _ocrBusy = false;
        });
        return;
      }
      _imageW = decoded.width;
      _imageH = decoded.height;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Erreur lecture: $e';
        _ocrBusy = false;
      });
      return;
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(widget.imagePath);
      final recognized = await recognizer.processImage(input);
      if (!mounted) return;
      final lines = <TextLine>[];
      for (final block in recognized.blocks) {
        lines.addAll(block.lines);
      }
      setState(() {
        _lines = lines;
        _ocrBusy = false;
        if (lines.isEmpty) {
          _ocrError =
              'Aucun texte détecté. Essayez une photo plus nette ou mieux éclairée.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ocrError = 'Reconnaissance impossible: $e';
        _ocrBusy = false;
      });
    } finally {
      await recognizer.close();
    }
  }

  String _norm(String? s) =>
      (s ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');

  void _onImageTap(Offset imagePoint) {
    if (_step >= 3 || _lines.isEmpty) return;
    var hitIndex = -1;
    for (var i = 0; i < _lines.length; i++) {
      final r = _lines[i].boundingBox;
      if (r.inflate(8).contains(imagePoint)) {
        hitIndex = i;
        break;
      }
    }
    if (hitIndex < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Touchez un texte détecté (cadre coloré).'),
        ),
      );
      return;
    }
    setState(() {
      _pickedLineIndex[_step] = hitIndex;
      _step++;
    });
  }

  void _undoLast() {
    if (_step <= 0) return;
    setState(() {
      _step--;
      _pickedLineIndex[_step] = null;
    });
  }

  void _resetPicks() {
    setState(() {
      _step = 0;
      _pickedLineIndex[0] = null;
      _pickedLineIndex[1] = null;
      _pickedLineIndex[2] = null;
    });
  }

  Future<void> _apply() async {
    final title = _pickedLineIndex[0] != null
        ? _norm(_lines[_pickedLineIndex[0]!].text)
        : '';
    final authors = _pickedLineIndex[1] != null
        ? _norm(_lines[_pickedLineIndex[1]!].text)
        : '';
    final publisher = _pickedLineIndex[2] != null
        ? _norm(_lines[_pickedLineIndex[2]!].text)
        : '';

    if (title.isEmpty && authors.isEmpty && publisher.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez les trois zones ou annulez.')),
      );
      return;
    }

    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (ctx) {
        final titleCtrl = TextEditingController(text: title);
        final authorsCtrl = TextEditingController(text: authors);
        final publisherCtrl = TextEditingController(text: publisher);
        return AlertDialog(
          title: const Text('Enregistrer dans la fiche'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Titre'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: authorsCtrl,
                  decoration: const InputDecoration(labelText: 'Auteur(s)'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: publisherCtrl,
                  decoration: const InputDecoration(labelText: 'Éditeur'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                titleCtrl.dispose();
                authorsCtrl.dispose();
                publisherCtrl.dispose();
                Navigator.pop(ctx, null);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final m = <String, String>{
                  'title': titleCtrl.text.trim(),
                  'authors': authorsCtrl.text.trim(),
                  'publisher': publisherCtrl.text.trim(),
                };
                titleCtrl.dispose();
                authorsCtrl.dispose();
                publisherCtrl.dispose();
                Navigator.pop(ctx, m);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (result == null || !mounted) return;

    final svc = context.read<BookService>();
    await svc.updateBookDetails(
      widget.bookId,
      title: result['title']!.isNotEmpty ? result['title'] : null,
      authors: result['authors']!.isNotEmpty ? result['authors'] : null,
      publisher: result['publisher']!.isNotEmpty ? result['publisher'] : null,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fiche mise à jour')),
    );
    Navigator.pop(context, true);
  }

  String _instruction() {
    switch (_step) {
      case 0:
        return '1/3 — Touchez la zone du titre sur l’image';
      case 1:
        return '2/3 — Touchez la zone de l’auteur (ou des auteurs)';
      case 2:
        return '3/3 — Touchez la zone de l’éditeur';
      default:
        return 'Vérifiez les sélections puis enregistrez.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Texte sur la couverture')),
        body: Center(child: Text(_loadError!)),
      );
    }

    if (_imageW == null || _imageH == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final imageSize = Size(_imageW!.toDouble(), _imageH!.toDouble());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Texte sur la couverture'),
        actions: [
          if (_step > 0 && _step <= 3)
            IconButton(
              tooltip: 'Annuler le dernier choix',
              icon: const Icon(Icons.undo),
              onPressed: _undoLast,
            ),
          if (_step > 0 || _pickedLineIndex.any((e) => e != null))
            TextButton(
              onPressed: _resetPicks,
              child: const Text('Recommencer'),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _ocrBusy
                      ? 'Analyse de l’image…'
                      : (_ocrError ?? _instruction()),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          Expanded(
            child: _ocrBusy
                ? const Center(child: CircularProgressIndicator())
                : _ocrError != null && _lines.isEmpty
                    ? Center(child: Text(_ocrError!))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final maxBox = Size(constraints.maxWidth, constraints.maxHeight);
                          final layout = _computeLayout(maxBox, imageSize);
                          return Stack(
                            children: [
                              Positioned(
                                left: layout.offset.dx,
                                top: layout.offset.dy,
                                width: layout.displayed.width,
                                height: layout.displayed.height,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: (d) {
                                    final imgPt = _toImageSpace(d.localPosition, layout);
                                    _onImageTap(imgPt);
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(widget.imagePath),
                                        fit: BoxFit.fill,
                                      ),
                                      CustomPaint(
                                        painter: _OcrLinesPainter(
                                          lines: _lines,
                                          scale: layout.scale,
                                          pickedIndices: _pickedLineIndex,
                                          step: _step,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
          if (!_ocrBusy && _lines.isNotEmpty)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _step >= 3 ? _apply : null,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Enregistrer dans la fiche'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OcrLinesPainter extends CustomPainter {
  _OcrLinesPainter({
    required this.lines,
    required this.scale,
    required this.pickedIndices,
    required this.step,
  });

  final List<TextLine> lines;
  final double scale;
  final List<int?> pickedIndices;
  final int step;

  static const _titleC = Color(0x6600BCD4);
  static const _authorC = Color(0x664CAF50);
  static const _publisherC = Color(0x66FF9800);
  static const _pendingC = Color(0x449E9E9E);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final r = line.boundingBox;
      final dr = Rect.fromLTWH(
        r.left * scale,
        r.top * scale,
        r.width * scale,
        r.height * scale,
      );

      var fill = _pendingC;
      if (pickedIndices[0] == i) fill = _titleC;
      if (pickedIndices[1] == i) fill = _authorC;
      if (pickedIndices[2] == i) fill = _publisherC;

      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = step <= 2 && pickedIndices.contains(i)
            ? Colors.blueGrey.shade700
            : Colors.white54;

      canvas.drawRect(dr, Paint()..color = fill);
      canvas.drawRect(dr, border);
    }
  }

  @override
  bool shouldRepaint(covariant _OcrLinesPainter oldDelegate) => true;
}
