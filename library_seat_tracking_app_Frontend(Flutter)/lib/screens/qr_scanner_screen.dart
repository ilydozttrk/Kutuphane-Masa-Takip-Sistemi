import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _isProcessing = false;

  // Debug modda emulator kamerası sorun çıkarabildiği için önce test ekranı açılır.
  // Release/final modda test butonları görünmez, direkt kamera açılır.
  bool _cameraStarted = !kDebugMode;

  Future<void> _handleQrCode(String qrCode) async {
    if (_isProcessing) return;

    final cleanedQrCode = qrCode.trim();

    if (cleanedQrCode.isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    if (_cameraStarted) {
      await _controller.stop();
    }

    if (!mounted) return;

    Navigator.pop(context, cleanedQrCode);
  }

  void _onDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;

    if (barcodes.isEmpty) {
      return;
    }

    final rawValue = barcodes.first.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) {
      return;
    }

    _handleQrCode(rawValue);
  }

  Future<void> _startCamera() async {
    if (_cameraStarted) return;

    setState(() {
      _cameraStarted = true;
    });
  }

  Future<void> _stopCameraAndReturnToTestMode() async {
    if (!_cameraStarted) return;

    await _controller.stop();

    if (!mounted) return;

    setState(() {
      _cameraStarted = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTestButton(String qrCode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleQrCode(qrCode),
        icon: const Icon(Icons.qr_code),
        label: Text(qrCode),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDebugTestModeView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 72,
            color: Colors.indigo,
          ),
          const SizedBox(height: 18),
          const Text(
            'QR Test Modu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bu alan sadece geliştirme modunda görünür. Final sürümde test QR butonları kapalıdır ve kullanıcı gerçek QR okutmak zorundadır.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          _buildTestButton('QR-A101-TEST'),
          const SizedBox(height: 12),
          _buildTestButton('QR-A102-TEST'),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _startCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Kamerayı Aç'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 28,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Masa üzerindeki QR kodu kare alanın içine getir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_cameraStarted) {
      return [
        IconButton(
          onPressed: () {
            _controller.toggleTorch();
          },
          icon: const Icon(Icons.flash_on),
        ),
        if (kDebugMode)
          IconButton(
            onPressed: _stopCameraAndReturnToTestMode,
            icon: const Icon(Icons.bug_report),
          ),
      ];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cameraStarted ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('QR Okut'),
        actions: _buildAppBarActions(),
      ),
      body: _cameraStarted ? _buildCameraView() : _buildDebugTestModeView(),
    );
  }
}