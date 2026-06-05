import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final String? rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _hasScanned = true);
    _controller.stop();

    // Extract plain address — some wallets encode as "bitcoin:ADDRESS?amount=0.001"
    final address = _extractAddress(rawValue);

    _showConfirmation(address, rawValue);
  }

  String _extractAddress(String raw) {
    // Strip common crypto URI prefixes: bitcoin:, ethereum:, etc.
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.scheme.isNotEmpty && uri.path.isNotEmpty) {
      return uri.path.split('?').first;
    }
    return raw;
  }

  void _showConfirmation(String address, String rawValue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _ConfirmSheet(
        address: address,
        onConfirm: () {
          Navigator.pop(context); // close sheet
          Navigator.pop(context, address); // return address to withdraw form
        },
        onRescan: () {
          Navigator.pop(context); // close sheet
          setState(() => _hasScanned = false);
          _controller.start();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan QR Code',
          style: AppTheme.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay with cutout
          _ScanOverlay(),

          // Bottom label
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align the QR code within the frame',
                style: AppTheme.inter(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confirmation bottom sheet ─────────────────────────────────────────────────
class _ConfirmSheet extends StatelessWidget {
  final String address;
  final VoidCallback onConfirm;
  final VoidCallback onRescan;

  const _ConfirmSheet({
    required this.address,
    required this.onConfirm,
    required this.onRescan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1D21),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4B53E).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFFE4B53E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'QR Code Scanned',
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Label
            Text(
              'Wallet Address',
              style: AppTheme.inter(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),

            // Address box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111113),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Text(
                address,
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Please confirm this is the correct recipient address before proceeding. Crypto transactions are irreversible.',
              style: AppTheme.inter(
                color: Colors.white38,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onRescan,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Re-scan',
                        style: AppTheme.inter(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Use This Address',
                        style: AppTheme.inter(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scan frame overlay ────────────────────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  static const double cutout = 260.0;
  static const double bracketLen = 28.0;
  static const double strokeWidth = 3.0;
  static const double cornerRadius = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Centre the cutout horizontally, slightly above vertical centre
    final left = (size.width - cutout) / 2;
    final top = (size.height - cutout) / 2.5;
    final rect = Rect.fromLTWH(left, top, cutout, cutout);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Dark overlay with transparent hole
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.65),
    );

    // Gold corner brackets
    final bracketPaint = Paint()
      ..color = const Color(0xFFE4B53E)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final r = left;
    final t = top;
    final br = left + cutout; // right edge
    final bt = top + cutout;  // bottom edge

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(r, t + bracketLen)
        ..lineTo(r, t + cornerRadius)
        ..arcToPoint(Offset(r + cornerRadius, t), radius: const Radius.circular(cornerRadius))
        ..lineTo(r + bracketLen, t),
      bracketPaint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(br - bracketLen, t)
        ..lineTo(br - cornerRadius, t)
        ..arcToPoint(Offset(br, t + cornerRadius), radius: const Radius.circular(cornerRadius))
        ..lineTo(br, t + bracketLen),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(r, bt - bracketLen)
        ..lineTo(r, bt - cornerRadius)
        ..arcToPoint(Offset(r + cornerRadius, bt), radius: const Radius.circular(cornerRadius))
        ..lineTo(r + bracketLen, bt),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(br - bracketLen, bt)
        ..lineTo(br - cornerRadius, bt)
        ..arcToPoint(Offset(br, bt - cornerRadius), radius: const Radius.circular(cornerRadius))
        ..lineTo(br, bt - bracketLen),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => false;
}
