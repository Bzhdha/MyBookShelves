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

Rect _normalizeRectFromOffsets(Offset a, Offset b) {
  final left = math.min(a.dx, b.dx);
  final top = math.min(a.dy, b.dy);
  final right = math.max(a.dx, b.dx);
  final bottom = math.max(a.dy, b.dy);
  return Rect.fromLTRB(left, top, right, bottom);
}

int _compareReadingOrder(List<TextLine> lines, int ai, int bi) {
  final ra = lines[ai].boundingBox;
  final rb = lines[bi].boundingBox;
  const band = 10.0;
  if ((ra.center.dy - rb.center.dy).abs() < band) {
    return ra.left.compareTo(rb.left);
  }
  return ra.top.compareTo(rb.top);
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
  /// Indices de lignes OCR par champ (titre, auteur, éditeur), ordre de lecture.
  final List<List<int>> _pickedLineGroups = [[], [], []];
  final Set<int> _ignoredLineIndices = {};
  bool _ignoreZonesMode = false;

  Offset? _dragAImage;
  Offset? _dragBImage;
  Offset? _panLocalStart;
  Offset? _panLocalEnd;

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

  /// Retire les fragments type balises `<...>` parfois lus à tort par l’OCR.
  String _stripTagLike(String s) => s.replaceAll(RegExp(r'<[^>]*>'), '');

  String _fieldTextFromIndices(List<int> indices) {
    if (indices.isEmpty) return '';
    final sorted = List<int>.from(indices)
      ..sort((a, b) => _compareReadingOrder(_lines, a, b));
    final raw = sorted.map((i) => _lines[i].text).join(' ');
    return _norm(_stripTagLike(raw));
  }

  int? _hitLineAt(Offset imagePoint, {bool respectIgnored = true}) {
    var hitIndex = -1;
    for (var i = 0; i < _lines.length; i++) {
      if (respectIgnored && _ignoredLineIndices.contains(i)) continue;
      final r = _lines[i].boundingBox;
      if (r.inflate(8).contains(imagePoint)) {
        hitIndex = i;
        break;
      }
    }
    return hitIndex >= 0 ? hitIndex : null;
  }

  void _toggleIgnoredAt(Offset imagePoint) {
    final hit = _hitLineAt(imagePoint, respectIgnored: false);
    if (hit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Touchez un cadre OCR pour l’ignorer ou le rétablir.')),
      );
      return;
    }
    setState(() {
      if (_ignoredLineIndices.contains(hit)) {
        _ignoredLineIndices.remove(hit);
      } else {
        _ignoredLineIndices.add(hit);
      }
    });
  }

  void _onImageTap(Offset imagePoint) {
    if (_step >= 3 || _lines.isEmpty) return;
    final hitIndex = _hitLineAt(imagePoint);
    if (hitIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ignoredLineIndices.isEmpty
                ? 'Touchez un texte détecté (cadre coloré), ou tracez un rectangle autour de plusieurs lignes.'
                : 'Zone ignorée ou hors cadre — désactivez « Ignorer des zones » ou choisissez une autre ligne.',
          ),
        ),
      );
      return;
    }
    setState(() {
      _pickedLineGroups[_step] = [hitIndex];
      _step++;
    });
  }

  void _onRectSelection(Rect imageRect) {
    if (_step >= 3 || _lines.isEmpty) return;
    final hits = <int>{};
    for (var i = 0; i < _lines.length; i++) {
      if (_ignoredLineIndices.contains(i)) continue;
      if (imageRect.overlaps(_lines[i].boundingBox)) {
        hits.add(i);
      }
    }
    if (hits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun texte dans le rectangle (hors zones ignorées).'),
        ),
      );
      return;
    }
    setState(() {
      _pickedLineGroups[_step] = hits.toList();
      _step++;
    });
  }

  void _undoLast() {
    if (_step <= 0) return;
    setState(() {
      _step--;
      _pickedLineGroups[_step] = [];
    });
  }

  void _resetPicks() {
    setState(() {
      _step = 0;
      _pickedLineGroups[0] = [];
      _pickedLineGroups[1] = [];
      _pickedLineGroups[2] = [];
    });
  }

  Future<void> _apply() async {
    final title = _fieldTextFromIndices(_pickedLineGroups[0]);
    final authors = _fieldTextFromIndices(_pickedLineGroups[1]);
    final publisher = _fieldTextFromIndices(_pickedLineGroups[2]);

    if (title.isEmpty && authors.isEmpty && publisher.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez au moins une zone (titre, auteur ou éditeur) ou annulez.'),
        ),
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
    if (_ignoreZonesMode) {
      return 'Mode ignorer : touchez les cadres à exclure (prix, logos…). Touchez de nouveau pour rétablir.';
    }
    switch (_step) {
      case 0:
        return '1/3 — Titre : touchez une ligne ou tracez un rectangle autour du bloc multi-lignes.';
      case 1:
        return '2/3 — Auteur(s) : idem (ligne ou rectangle).';
      case 2:
        return '3/3 — Éditeur : idem.';
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
          IconButton(
            tooltip: _ignoreZonesMode ? 'Quitter le mode ignorer' : 'Ignorer des zones OCR',
            icon: Icon(
              _ignoreZonesMode ? Icons.filter_alt_off : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() => _ignoreZonesMode = !_ignoreZonesMode);
            },
          ),
          if (_step > 0 && _step <= 3)
            IconButton(
              tooltip: 'Annuler le dernier choix',
              icon: const Icon(Icons.undo),
              onPressed: _undoLast,
            ),
          if (_step > 0 || _pickedLineGroups.any((g) => g.isNotEmpty))
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
                                  onPanStart: (d) {
                                    setState(() {
                                      _panLocalStart = d.localPosition;
                                      _panLocalEnd = d.localPosition;
                                      _dragAImage = _toImageSpace(d.localPosition, layout);
                                      _dragBImage = _dragAImage;
                                    });
                                  },
                                  onPanUpdate: (d) {
                                    setState(() {
                                      _panLocalEnd = d.localPosition;
                                      _dragBImage = _toImageSpace(d.localPosition, layout);
                                    });
                                  },
                                  onPanEnd: (d) {
                                    _panLocalEnd = d.localPosition;
                                    final localDist = (_panLocalEnd! - _panLocalStart!).distance;
                                    final a = _dragAImage!;
                                    final b = _dragBImage!;

                                    setState(() {
                                      _dragAImage = null;
                                      _dragBImage = null;
                                      _panLocalStart = null;
                                      _panLocalEnd = null;
                                    });

                                    if (_ignoreZonesMode) {
                                      _toggleIgnoredAt(a);
                                      return;
                                    }
                                    if (_step >= 3) return;

                                    const tapSlop = 14.0;
                                    if (localDist < tapSlop) {
                                      _onImageTap(a);
                                      return;
                                    }

                                    final imageRect = _normalizeRectFromOffsets(a, b);
                                    final minSide = 12.0 / layout.scale;
                                    if (imageRect.width < minSide || imageRect.height < minSide) {
                                      _onImageTap(a);
                                      return;
                                    }
                                    _onRectSelection(imageRect);
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
                                          pickedGroups: _pickedLineGroups,
                                          ignoredIndices: _ignoredLineIndices,
                                          draftRectImage: (_dragAImage != null && _dragBImage != null)
                                              ? _normalizeRectFromOffsets(_dragAImage!, _dragBImage!)
                                              : null,
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

Rect _unionBounding(Iterable<Rect> rects) {
  final it = rects.iterator;
  if (!it.moveNext()) return Rect.zero;
  var l = it.current.left;
  var t = it.current.top;
  var r = it.current.right;
  var b = it.current.bottom;
  while (it.moveNext()) {
    final x = it.current;
    l = math.min(l, x.left);
    t = math.min(t, x.top);
    r = math.max(r, x.right);
    b = math.max(b, x.bottom);
  }
  return Rect.fromLTRB(l, t, r, b);
}

class _OcrLinesPainter extends CustomPainter {
  _OcrLinesPainter({
    required this.lines,
    required this.scale,
    required this.pickedGroups,
    required this.ignoredIndices,
    this.draftRectImage,
  });

  final List<TextLine> lines;
  final double scale;
  final List<List<int>> pickedGroups;
  final Set<int> ignoredIndices;
  final Rect? draftRectImage;

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

      if (ignoredIndices.contains(i)) {
        canvas.drawRect(dr, Paint()..color = const Color(0x22000000));
        canvas.drawRect(
          dr,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = Colors.red.withValues(alpha: 0.4),
        );
        continue;
      }

      var fill = _pendingC;
      int? pickedStep;
      for (var s = 0; s < pickedGroups.length; s++) {
        if (pickedGroups[s].contains(i)) {
          pickedStep = s;
          break;
        }
      }
      if (pickedStep != null) {
        fill = pickedStep == 0
            ? _titleC
            : pickedStep == 1
                ? _authorC
                : _publisherC;
      }

      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = pickedStep != null ? Colors.blueGrey.shade700 : Colors.white54;

      canvas.drawRect(dr, Paint()..color = fill);
      canvas.drawRect(dr, border);
    }

    for (var s = 0; s < pickedGroups.length; s++) {
      final g = pickedGroups[s];
      if (g.length < 2) continue;
      final rects = g.map((idx) => lines[idx].boundingBox).toList();
      final u = _unionBounding(rects);
      final dr = Rect.fromLTWH(
        u.left * scale,
        u.top * scale,
        u.width * scale,
        u.height * scale,
      );
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = s == 0
            ? const Color(0xCC00ACC1)
            : s == 1
                ? const Color(0xCC2E7D32)
                : const Color(0xCCEF6C00);
      canvas.drawRect(dr, stroke);
    }

    if (draftRectImage != null) {
      final r = draftRectImage!;
      final dr = Rect.fromLTWH(
        r.left * scale,
        r.top * scale,
        r.width * scale,
        r.height * scale,
      );
      canvas.drawRect(
        dr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black.withValues(alpha: 0.45),
      );
      canvas.drawRect(
        dr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.95),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OcrLinesPainter oldDelegate) => true;
}
