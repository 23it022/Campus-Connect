import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/constants/constants.dart';
import '../../data/services/qr_scanner_service.dart';
import '../providers/qr_scanner_provider.dart';

/// QR Scanner Screen
/// Camera-based QR code scanner with overlay, torch toggle,
/// and contextual result handling for CampusConnect deep links

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _hasScanned = true);
    _scannerController.stop();

    final provider = context.read<QrScannerProvider>();
    provider.processScan(barcode.rawValue!).then((_) {
      if (mounted) {
        _showResultSheet(provider.lastResult!);
      }
    });
  }

  void _resumeScanning() {
    setState(() => _hasScanned = false);
    context.read<QrScannerProvider>().clearLastResult();
    _scannerController.start();
  }

  void _showResultSheet(QrScanResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ResultBottomSheet(
        result: result,
        resolvedName: context.read<QrScannerProvider>().resolvedName,
        onDismiss: () {
          Navigator.pop(ctx);
          _resumeScanning();
        },
        onAction: () {
          Navigator.pop(ctx);
          _handleAction(result);
        },
      ),
    );
  }

  void _handleAction(QrScanResult result) {
    switch (result.type) {
      case QrContentType.profile:
        // Navigate to profile (or show info)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening profile: ${result.id}'),
            backgroundColor: AppColors.primary,
          ),
        );
        _resumeScanning();
        break;
      case QrContentType.event:
        if (result.id != null) {
          Navigator.pushNamed(context, '/events/${result.id}');
        }
        break;
      case QrContentType.group:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening group: ${result.id}'),
            backgroundColor: AppColors.success,
          ),
        );
        _resumeScanning();
        break;
      case QrContentType.url:
        _launchUrl(result.rawData);
        _resumeScanning();
        break;
      case QrContentType.text:
        _resumeScanning();
        break;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Dark overlay with transparent scan window
          _ScanOverlay(animation: _animation),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _buildCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  // Title
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Torch toggle
                  _buildCircleButton(
                    icon: Icons.flash_on,
                    onTap: () => _scannerController.toggleTorch(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: const Text(
                    'Point your camera at a QR code',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // History button
                TextButton.icon(
                  onPressed: () => _showHistorySheet(),
                  icon: const Icon(Icons.history, color: Colors.white70, size: 18),
                  label: const Text(
                    'Scan History',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  void _showHistorySheet() {
    final history = context.read<QrScannerProvider>().scanHistory;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Scan History', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No scans yet',
                  style: TextStyle(color: AppColors.grey),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final item = history[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColorForType(item.type).withOpacity(0.1),
                        child: Icon(
                          _getIconForType(item.type),
                          color: _getColorForType(item.type),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.displayLabel,
                        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        item.rawData,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(QrContentType type) {
    switch (type) {
      case QrContentType.profile: return Icons.person;
      case QrContentType.event: return Icons.event;
      case QrContentType.group: return Icons.group;
      case QrContentType.url: return Icons.link;
      case QrContentType.text: return Icons.text_snippet;
    }
  }

  Color _getColorForType(QrContentType type) {
    switch (type) {
      case QrContentType.profile: return AppColors.primary;
      case QrContentType.event: return AppColors.warning;
      case QrContentType.group: return AppColors.success;
      case QrContentType.url: return AppColors.info;
      case QrContentType.text: return AppColors.grey;
    }
  }
}

// =============================================================================
// Scan Overlay
// =============================================================================

class _ScanOverlay extends StatelessWidget {
  final Animation<double> animation;

  const _ScanOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanArea = size.width * 0.7;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _ScanOverlayPainter(
            scanAreaSize: scanArea,
            animationValue: animation.value,
          ),
        );
      },
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final double animationValue;

  _ScanOverlayPainter({
    required this.scanAreaSize,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 40);
    final halfScan = scanAreaSize / 2;

    // Dark overlay
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);
    final scanRect = Rect.fromCenter(
      center: center,
      width: scanAreaSize,
      height: scanAreaSize,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16))),
      ),
      overlayPaint,
    );

    // Corner brackets
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 30.0;
    const r = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - halfScan, center.dy - halfScan + cornerLen)
        ..lineTo(center.dx - halfScan, center.dy - halfScan + r)
        ..quadraticBezierTo(
          center.dx - halfScan, center.dy - halfScan,
          center.dx - halfScan + r, center.dy - halfScan,
        )
        ..lineTo(center.dx - halfScan + cornerLen, center.dy - halfScan),
      cornerPaint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + halfScan - cornerLen, center.dy - halfScan)
        ..lineTo(center.dx + halfScan - r, center.dy - halfScan)
        ..quadraticBezierTo(
          center.dx + halfScan, center.dy - halfScan,
          center.dx + halfScan, center.dy - halfScan + r,
        )
        ..lineTo(center.dx + halfScan, center.dy - halfScan + cornerLen),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - halfScan, center.dy + halfScan - cornerLen)
        ..lineTo(center.dx - halfScan, center.dy + halfScan - r)
        ..quadraticBezierTo(
          center.dx - halfScan, center.dy + halfScan,
          center.dx - halfScan + r, center.dy + halfScan,
        )
        ..lineTo(center.dx - halfScan + cornerLen, center.dy + halfScan),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + halfScan - cornerLen, center.dy + halfScan)
        ..lineTo(center.dx + halfScan - r, center.dy + halfScan)
        ..quadraticBezierTo(
          center.dx + halfScan, center.dy + halfScan,
          center.dx + halfScan, center.dy + halfScan - r,
        )
        ..lineTo(center.dx + halfScan, center.dy + halfScan - cornerLen),
      cornerPaint,
    );

    // Animated scan line
    final lineY = center.dy - halfScan +
        (scanAreaSize * animationValue);
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0),
          AppColors.primary.withOpacity(0.8),
          AppColors.primary.withOpacity(0),
        ],
      ).createShader(
        Rect.fromLTWH(center.dx - halfScan, lineY, scanAreaSize, 2),
      )
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(center.dx - halfScan + 16, lineY),
      Offset(center.dx + halfScan - 16, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter old) =>
      old.animationValue != animationValue;
}

// =============================================================================
// Result Bottom Sheet
// =============================================================================

class _ResultBottomSheet extends StatelessWidget {
  final QrScanResult result;
  final String? resolvedName;
  final VoidCallback onDismiss;
  final VoidCallback onAction;

  const _ResultBottomSheet({
    required this.result,
    this.resolvedName,
    required this.onDismiss,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getResultIcon(),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Type label
          Text(
            result.displayLabel,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Resolved name or raw data
          if (resolvedName != null) ...[
            Text(
              resolvedName!,
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
          ],
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              result.rawData,
              style: AppTextStyles.caption.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: const Text('Scan Again', style: TextStyle(color: AppColors.greyDark)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.button,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: Text(
                      _getActionLabel(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  IconData _getResultIcon() {
    switch (result.type) {
      case QrContentType.profile: return Icons.person;
      case QrContentType.event: return Icons.event;
      case QrContentType.group: return Icons.group;
      case QrContentType.url: return Icons.link;
      case QrContentType.text: return Icons.text_snippet;
    }
  }

  String _getActionLabel() {
    switch (result.type) {
      case QrContentType.profile: return 'View Profile';
      case QrContentType.event: return 'View Event';
      case QrContentType.group: return 'View Group';
      case QrContentType.url: return 'Open Link';
      case QrContentType.text: return 'Copy Text';
    }
  }
}
