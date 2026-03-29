import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../domain/book_service.dart';
import '../../settings/data/scan_settings_store.dart';
import '../../settings/ui/scan_settings_page.dart';
import 'cover_photo_page.dart';

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

  String? _pendingIsbn; // ISBN en attente de validation
  String? _lastAcceptedIsbn; // anti doublon "validation"
  DateTime? _lastAcceptedAt;

  /// Livre venant d'être ajouté : affiché en bannière en haut quelques secondes.
  Book? _lastAddedBookForBanner;
  bool _showAddedBookBanner = false;
  Timer? _bannerHideTimer;

  bool get _isPausedForValidation => _pendingIsbn != null;

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

  Future<void> _onValidate(BookService bookService, String isbn) async {
    if (widget.lookupOnly) {
      _lastAcceptedIsbn = isbn;
      _lastAcceptedAt = DateTime.now();
      if (!mounted) return;
      Navigator.pop<String>(context, isbn);
      return;
    }

    final bookId = await bookService.addOrUpdateFromIsbnScan(isbn);

    _lastAcceptedIsbn = isbn;
    _lastAcceptedAt = DateTime.now();

    if (!mounted) return;
    final book = await bookService.getBook(bookId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ajouté : ${book?.title ?? isbn}')),
    );

    final scanSettings = context.read<ScanSettingsStore>();
    if (scanSettings.photoCoverEnabled && mounted) {
      try {
        final result = await Navigator.push<CoverPhotoResult>(
          context,
          MaterialPageRoute(
            builder: (_) => CoverPhotoPage(bookId: bookId),
          ),
        );
        if (result != null && result.coverPath != null && mounted) {
          await bookService.updateBookCoverFromScan(bookId, result.coverPath!);
        }
      } finally {
        if (mounted) {
          setState(() {
            _pendingIsbn = null;
            _lastAddedBookForBanner = book;
            _showAddedBookBanner = true;
          });
          _scheduleBannerHide();
          _resumeScannerAfterReturn();
        }
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _pendingIsbn = null;
      _lastAddedBookForBanner = book;
      _showAddedBookBanner = true;
    });
    _scheduleBannerHide();
    await _controller.start();
  }

  /// Redémarre le lecteur après un retour de navigation (ex. CoverPhotoPage).
  /// Reporte le start() au prochain frame + court délai pour que la caméra
  /// libérée par l'écran précédent soit bien disponible.
  void _resumeScannerAfterReturn() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      await _controller.start();
    });
  }

  Future<void> _onReject() async {
    setState(() => _pendingIsbn = null);
    await _controller.start();
  }

  Future<void> _pauseWithIsbn(String isbn) async {
    // On ne garde que les ISBN "probables" (tu peux enlever ce filtre si tu veux tout accepter)
    if (isbn.length == 13 && !_isProbablyIsbn13(isbn)) return;

    setState(() => _pendingIsbn = isbn);
    await _controller.stop();
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
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            onDetect: (capture) async {
              if (_isPausedForValidation) return;

              // On prend le 1er code détecté
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final raw = barcodes.first.rawValue;
              final isbn = _normalizeIsbn(raw);
              if (isbn == null) return;

              if (_shouldIgnoreDetection(isbn)) return;

              await _pauseWithIsbn(isbn);
            },
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

          // Carte de validation (bas)
          if (_pendingIsbn != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                minimum: const EdgeInsets.all(12),
                child: Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Détection',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _pendingIsbn!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.lookupOnly
                                    ? 'Valider pour utiliser ce code'
                                    : 'Valider pour ajouter et passer à la BD suivante',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _onReject,
                          tooltip: 'Rejeter',
                        ),
                        const SizedBox(width: 4),
                        FilledButton.icon(
                          onPressed: () =>
                              _onValidate(bookService, _pendingIsbn!),
                          icon: const Icon(Icons.check),
                          label: const Text('Valider'),
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
