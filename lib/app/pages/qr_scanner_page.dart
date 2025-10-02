import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/oeuvre_controller.dart';
import '../utils/app_color.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final OeuvreController controller = Get.find<OeuvreController>();
  bool isFlashOn = false;
  bool hasScanned = false;

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    scannerController.toggleTorch();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() {
        hasScanned = true;
      });
      
      final String code = barcodes.first.rawValue!;
      controller.scanQrCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: _onDetect,
          ),
          // Overlay personnalisé
          CustomPaint(
            painter: ScannerOverlayPainter(
              scanWindow: Rect.fromCenter(
                center: Offset(Get.width / 2, Get.height / 2),
                width: Get.width * 0.7,
                height: Get.width * 0.7,
              ),
              borderColor: AppColors.primary,
            ),
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.surface.withOpacity(0.9),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        backgroundColor: AppColors.surface.withOpacity(0.9),
                        child: IconButton(
                          icon: Icon(
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scanner le QR Code',
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Placez le QR Code dans le cadre pour découvrir l\'œuvre',
                        textAlign: TextAlign.center,
                        style: Get.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Painter pour créer l'overlay personnalisé
class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;

  ScannerOverlayPainter({
    required this.scanWindow,
    this.borderColor = Colors.white,
    this.borderWidth = 8.0,
    this.borderLength = 40.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner l'overlay sombre
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        scanWindow,
        Radius.circular(borderRadius),
      ));

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    // Dessiner les coins
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Coin supérieur gauche
    canvas.drawPath(
      Path()
        ..moveTo(scanWindow.left + borderRadius, scanWindow.top)
        ..lineTo(scanWindow.left + borderLength, scanWindow.top)
        ..moveTo(scanWindow.left, scanWindow.top + borderRadius)
        ..lineTo(scanWindow.left, scanWindow.top + borderLength),
      paint,
    );

    // Coin supérieur droit
    canvas.drawPath(
      Path()
        ..moveTo(scanWindow.right - borderLength, scanWindow.top)
        ..lineTo(scanWindow.right - borderRadius, scanWindow.top)
        ..moveTo(scanWindow.right, scanWindow.top + borderRadius)
        ..lineTo(scanWindow.right, scanWindow.top + borderLength),
      paint,
    );

    // Coin inférieur gauche
    canvas.drawPath(
      Path()
        ..moveTo(scanWindow.left, scanWindow.bottom - borderLength)
        ..lineTo(scanWindow.left, scanWindow.bottom - borderRadius)
        ..moveTo(scanWindow.left + borderRadius, scanWindow.bottom)
        ..lineTo(scanWindow.left + borderLength, scanWindow.bottom),
      paint,
    );

    // Coin inférieur droit
    canvas.drawPath(
      Path()
        ..moveTo(scanWindow.right, scanWindow.bottom - borderLength)
        ..lineTo(scanWindow.right, scanWindow.bottom - borderRadius)
        ..moveTo(scanWindow.right - borderRadius, scanWindow.bottom)
        ..lineTo(scanWindow.right - borderLength, scanWindow.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderColor != oldDelegate.borderColor;
  }
}