import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../domain/book_service.dart';
import '../../settings/ui/scan_settings_page.dart';
import 'cover_photo_page.dart';
import 'book_detail_page.dart';

class IsbnScannerPage extends StatefulWidget {
  const IsbnScannerPage({
    super.key,
    this.lookupOnly = false,
  });

  /// Si vrai, renvoie l'ISBN/EAN normalisé via [Navigator.pop] sans créer ni enrichir de fiche.
  final bool lookupOnly;

  @override
  State<IsbnScannerPage> createState() => _IsbnScannerPageState();
}

class _IsbnScannerPageState extends State<IsbnScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  /// ISBN en cours de recherche / création fiche (affiche un chargement).
  String? _processingIsbn;

  /// Après ajout : livre affiché dans la carte d'actions (autre scan ou photos).
  Book? _choiceBook;
  String? _choiceBookId;

  String? _lastAcceptedIsbn; // anti doublon scan rapproché
  DateTime? _lastAcceptedAt;

  /// Livre venant d'être ajouté : affiché en bannière en haut quelques secondes.
  Book? _lastAddedBookForBanner;
  bool _showAddedBookBanner = false;
  Timer? _bannerHideTimer;

  bool get _blocksBarcodeDetection =>
      _processingIsbn != null || _choiceBook != null;

  String get _isbnLineForChoiceCard {
    final fromBook = _choiceBook?.isbn?.trim();
    if (fromBook != null && fromBook.isNotEmpty) return 'ISBN $fromBook';
    if (_lastAcceptedIsbn != null) return 'ISBN $_lastAcceptedIsbn';
    return 'ISBN —';
  }

  static const Duration _bannerDisplayDuration = Duration(seconds: 4);

  @override
  void dispose() {
    _bannerHideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleBannerHide() {
    _bannerHideTimer?.cancel();
    _bannerHideTimer = Timer(_bannerDisplayDuration, () {
      if (mounted) setState(() => _showAddedBookBanner = false);
    });
  }

  // Garde uniquement les chiffres + filtre ISBN/EAN13
  String? _normalizeIsbn(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 13) return digits; // EAN-13 (souvent ISBN-13)
    if (digits.length == 10) return digits; // ISBN-10 (si saisi / détecté)
    return null;
  }

  bool _isProbablyIsbn13(String isbn) {
    // La plupart des ISBN-13 commencent par 978 / 979
    if (isbn.length != 13) return false;
    return isbn.startsWith('978') || isbn.startsWith('979');
  }

  bool _shouldIgnoreDetection(String isbn) {
    // Evite de re-proposer immédiatement le même ISBN
    if (_lastAcceptedIsbn == null || _lastAcceptedAt == null) return false;
    if (_lastAcceptedIsbn != isbn) return false;
    return DateTime.now().difference(_lastAcceptedAt!) < const Duration(seconds: 2);
  }

  Future<void> _resumeScanning() async {
    if (!mounted) return;
    setState(() {
      _processingIsbn = null;
      _choiceBook = null;
      _choiceBookId = null;
    });
    await _controller.start();
  }

  Future<void> _applyCoverPhotoResult(
    BookService bookService,
    String bookId,
    CoverPhotoResult? result,
  ) async {
    if (result == null) return;
    if (result.coverPath != null) {
      await bookService.updateBookCoverFromScan(bookId, result.coverPath!);
    }
  }

  Future<void> _onChooseCoverPhotos(
    BookService bookService,
    String bookId,
    Book book,
  ) async {
    try {
      final result = await Navigator.push<CoverPhotoResult?>(
        context,
        MaterialPageRoute(
          builder: (_) => CoverPhotoPage(bookId: bookId),
        ),
      );
      if (!mounted) return;
      await _applyCoverPhotoResult(bookService, bookId, result);
    } finally {
      if (mounted) {
        setState(() {
          _choiceBook = null;
          _choiceBookId = null;
          _lastAddedBookForBanner = book;
          _showAddedBookBanner = true;
        });
        _scheduleBannerHide();
        _resumeScannerAfterReturn();
      }
    }
  }

  Future<void> _onScanAnotherBook(Book book) async {
    if (!mounted) return;
    setState(() {
      _choiceBook = null;
      _choiceBookId = null;
      _lastAddedBookForBanner = book;
      _showAddedBookBanner = true;
    });
    _scheduleBannerHide();
    await _controller.start();
  }

  /// Recherche et création d'exemplaire dès la détection du code-barres.
  Future<void> _processIsbnAfterDetection(
    BookService bookService,
    String isbn,
  ) async {
    if (widget.lookupOnly) {
      _lastAcceptedIsbn = isbn;
      _lastAcceptedAt = DateTime.now();
      if (!mounted) return;
      await _controller.stop();
      if (!mounted) return;
      Navigator.pop<String>(context, isbn);
      return;
    }

    setState(() => _processingIsbn = isbn);
    await _controller.stop();

    try {
      final existing = await bookService.findExistingByIsbn(isbn);
      if (!mounted) return;

      if (existing != null) {
        setState(() => _processingIsbn = null);
        final copies = await bookService.countCopies(existing.id);
        if (!mounted) return;
        final action = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Livre déjà présent'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('« ${existing.title} »',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (existing.authors.isNotEmpty) Text(existing.authors),
                const SizedBox(height: 8),
                Text(
                  'Vous possédez déjà $copies exemplaire${copies > 1 ? 's' : ''}.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'cancel'),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'view'),
                child: const Text('Voir'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, 'add'),
                child: const Text('Ajouter quand même'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (action == 'cancel' || action == null) {
          await _resumeScanning();
          return;
        }
        if (action == 'view') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailPage(bookId: existing.id),
            ),
          );
          _resumeScannerAfterReturn();
          return;
        }
        setState(() => _processingIsbn = isbn);
      }

      final bookId = await bookService.addOrUpdateFromIsbnScan(isbn);
      _lastAcceptedIsbn = isbn;
      _lastAcceptedAt = DateTime.now();

      if (!mounted) return;
      final book = await bookService.getBook(bookId);
      if (!mounted) return;
      if (book == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Livre introuvable après enregistrement.')),
          );
          await _resumeScanning();
        }
        return;
      }

      setState(() {
        _processingIsbn = null;
        _choiceBook = book;
        _choiceBookId = bookId;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ajouter le livre : $e')),
        );
        await _resumeScanning();
      }
    }
  }

  /// Redémarre le lecteur après un retour de navigation (ex. [CoverPhotoPage] avec le package `camera`).
  /// Stop explicite + délai : après le dos, le capteur est encore souvent verrouillé quelques centaines de ms.
  Future<void> _restartMobileScannerAfterCameraHandoff() async {
    if (!mounted) return;
    try {
      await _controller.stop();
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await _controller.start();
        return;
      } catch (_) {
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
    }
  }

  void _resumeScannerAfterReturn() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_restartMobileScannerAfterCameraHandoff());
    });
  }


  @override
  Widget build(BuildContext context) {
    final bookService = context.read<BookService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lookupOnly ? 'Scanner un ISBN / EAN' : 'Scan ISBN (enchaîné)',
        ),
        actions: [
          if (!widget.lookupOnly)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanSettingsPage()),
                );
              },
              tooltip: 'Paramètres scan (photo couverture/dos)',
            ),
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (_, state, __) {
                final isOn = state.torchState == TorchState.on;
                return Icon(
                  isOn ? Icons.flash_on : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
            tooltip: 'Flash',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Sortir',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            onDetect: (capture) async {
              if (_blocksBarcodeDetection) return;

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final raw = barcodes.first.rawValue;
              final isbn = _normalizeIsbn(raw);
              if (isbn == null) return;

              if (isbn.length == 13 && !_isProbablyIsbn13(isbn)) return;

              if (_shouldIgnoreDetection(isbn)) return;

              await _processIsbnAfterDetection(bookService, isbn);
            },
          ),

          // Bannière "livre ajouté" en haut, quelques secondes
          if (_showAddedBookBanner && _lastAddedBookForBanner != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Référence ajoutée',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withValues(alpha: 0.9),
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _lastAddedBookForBanner!.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (_lastAddedBookForBanner!.authors
                                        .trim()
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _lastAddedBookForBanner!.authors,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withValues(alpha: 0.85),
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Overlay simple (viseur)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 260,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(width: 3, color: Colors.white),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          // Recherche en cours
          if (!widget.lookupOnly && _processingIsbn != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                minimum: const EdgeInsets.all(12),
                child: Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _processingIsbn!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recherche et enregistrement…',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _resumeScanning,
                          child: const Text('Annuler'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Fiche ajoutée : enchaîner un autre ISBN ou prendre couverture / dos
          if (!widget.lookupOnly &&
              _choiceBook != null &&
              _choiceBookId != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                minimum: const EdgeInsets.all(12),
                child: Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Référence enregistrée',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _choiceBook!.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_choiceBook!.authors.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _choiceBook!.authors,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          _isbnLineForChoiceCard,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              _onScanAnotherBook(_choiceBook!),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scanner un autre livre'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _onChooseCoverPhotos(
                            bookService,
                            _choiceBookId!,
                            _choiceBook!,
                          ),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Photographier couverture et dos'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
