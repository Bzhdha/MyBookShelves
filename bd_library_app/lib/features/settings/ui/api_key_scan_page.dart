import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Page de scan d'un QR code contenant la clé API OpenAI.
/// Retourne la chaîne lue via [Navigator.pop(context, value].
class ApiKeyScanPage extends StatefulWidget {
  const ApiKeyScanPage({super.key});

  @override
  State<ApiKeyScanPage> createState() => _ApiKeyScanPageState();
}

class _ApiKeyScanPageState extends State<ApiKeyScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _hasResult = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasResult) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;
    _hasResult = true;
    if (!mounted) return;
    Navigator.pop(context, raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner la clé API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Annuler',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            onDetect: _onDetect,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(width: 3, color: Colors.white),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Text(
              'Cadrez le QR code contenant votre clé API OpenAI',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, shadows: [
                Shadow(blurRadius: 8, color: Colors.black),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
