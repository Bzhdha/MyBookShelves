import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../features/books/domain/book_service.dart';

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

  Future<void> _onValidate(BookService bookService, String isbn) async {
    await bookService.addOrUpdateFromIsbnScan(isbn);

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
    final bookService = context.read<BookService>();

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
