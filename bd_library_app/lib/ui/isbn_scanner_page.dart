import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import '../services/metadata_service.dart';
import '../services/open_library_provider.dart';
import '../services/cover_cache_service.dart';

import '../db/app_db.dart';

class IsbnScannerPage extends StatefulWidget {
  const IsbnScannerPage({super.key});

  @override
  State<IsbnScannerPage> createState() => _IsbnScannerPageState();
}

class _IsbnScannerPageState extends State<IsbnScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final MetadataService _metadataService =
      MetadataService(openLibrary: OpenLibraryProvider());

  final CoverCacheService _coverCacheService = CoverCacheService();

  String? _pendingIsbn; // ISBN en attente de validation
  String? _lastAcceptedIsbn; // anti doublon “validation”
  DateTime? _lastAcceptedAt;

  bool get _isPausedForValidation => _pendingIsbn != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<void> _onValidate(AppDb db, String isbn) async {
    final works = await db.findWorksByIsbn(isbn);

    String bookId;
    if (works.isEmpty) {
      // 1) On tente de récupérer les métadonnées via sites ouverts (OpenLibrary)
      final meta = await _metadataService.enrichFromIsbn(isbn);

      // 2) Création de l’œuvre
      bookId = const Uuid().v4();

      final title = (meta?.title?.trim().isNotEmpty ?? false)
          ? meta!.title!.trim()
          : 'ISBN $isbn';

      final authorsCsv = (meta?.authors != null && meta!.authors!.isNotEmpty)
          ? meta.authors!.join(', ')
          : '';

      final coverUrl = meta?.coverUrl;

      // 3) (optionnel mais top) télécharger la cover en local
      final coverLocalPath = await _coverCacheService.downloadCoverToLocalPath(
        bookId: bookId,
        coverUrl: coverUrl,
      );

      await db.upsertBook(
        BooksCompanion.insert(
          id: bookId,
          isbn: Value(isbn),
          title: title,
          authors: Value(authorsCsv),
          publisher: Value(meta?.publisher),
          publishedDate: Value(meta?.publishedDate),
          coverUrl: Value(coverUrl),
          coverLocalPath: Value(coverLocalPath),
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      // Œuvre déjà existante : on réutilise
      final existing = works.first;
      bookId = existing.id;

      // (Optionnel) enrichir si c’est encore un placeholder "ISBN ..."
      final isPlaceholderTitle = existing.title.trim() == 'ISBN $isbn';

      final missingCoreInfo =
          isPlaceholderTitle ||
          (existing.publisher == null || existing.publisher!.trim().isEmpty) ||
          (existing.publishedDate == null || existing.publishedDate!.trim().isEmpty) ||
          (existing.coverUrl == null || existing.coverUrl!.trim().isEmpty);

      if (missingCoreInfo) {
        final meta = await _metadataService.enrichFromIsbn(isbn);
        if (meta != null) {
          final newTitle = isPlaceholderTitle && (meta.title?.trim().isNotEmpty ?? false)
              ? meta.title!.trim()
              : existing.title;

          final newAuthors = (existing.authors.trim().isEmpty &&
                  meta.authors != null &&
                  meta.authors!.isNotEmpty)
              ? meta.authors!.join(', ')
              : existing.authors;

          final newCoverUrl = (existing.coverUrl == null || existing.coverUrl!.trim().isEmpty)
              ? meta.coverUrl
              : existing.coverUrl;

          String? newCoverLocalPath = existing.coverLocalPath;
          if ((newCoverLocalPath == null || newCoverLocalPath.trim().isEmpty) &&
              (newCoverUrl != null && newCoverUrl.trim().isNotEmpty)) {
            newCoverLocalPath = await _coverCacheService.downloadCoverToLocalPath(
              bookId: bookId,
              coverUrl: newCoverUrl,
            );
          }

          await db.upsertBook(
            BooksCompanion(
              id: Value(bookId),
              isbn: Value(isbn),
              title: Value(newTitle),
              authors: Value(newAuthors),
              publisher: Value(existing.publisher?.trim().isNotEmpty == true ? existing.publisher : meta.publisher),
              publishedDate: Value(existing.publishedDate?.trim().isNotEmpty == true ? existing.publishedDate : meta.publishedDate),
              coverUrl: Value(newCoverUrl),
              coverLocalPath: Value(newCoverLocalPath),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    }

    // 4) On crée un exemplaire (doublons gérés ici)
    final copyId = const Uuid().v4();
    await db.upsertCopy(
      CopiesCompanion.insert(
        id: copyId,
        bookId: bookId,
        updatedAt: DateTime.now(),
      ),
    );

    _lastAcceptedIsbn = isbn;
    _lastAcceptedAt = DateTime.now();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ajouté : $isbn')),
    );

    setState(() => _pendingIsbn = null);
    await _controller.start();
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
    final db = context.read<AppDb>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan ISBN (enchaîné)'),
        actions: [
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
                              const Text(
                                'Valider pour ajouter et passer à la BD suivante',
                                style: TextStyle(fontSize: 12),
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
                          onPressed: () => _onValidate(db, _pendingIsbn!),
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
