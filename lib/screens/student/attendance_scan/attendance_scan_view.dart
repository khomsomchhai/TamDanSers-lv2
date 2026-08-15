import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/screens/student/attendance_scan/attendance_scan_controller.dart';

part 'attendance_scan_binding.dart';

class AttendanceScanView extends GetView<AttendanceScanController> {
  const AttendanceScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double scanSize = screenSize.width * 0.72;
    final double scanLeft = (screenSize.width - scanSize) / 2;
    final double scanTop = screenSize.height / 2.3 - scanSize / 2;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: AppColors.darkBackground,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        title: Text(
          'scan_title'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // =================================================
          // CAMERA
          // =================================================

          Positioned.fill(
            child: MobileScanner(
              controller: controller.scannerController,
              onDetect: (BarcodeCapture capture) {
                if (capture.barcodes.isEmpty) return;
                final String? token = capture.barcodes.first.rawValue;
                if (token == null) return;
                controller.scanQr(token);
              },
            ),
          ),

          // =================================================
          // DARK OVERLAY WITH CUTOUT
          // =================================================

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ScannerOverlayPainter(),
              ),
            ),
          ),

          // =================================================
          // ANIMATED SCAN LINE
          // =================================================

          Positioned.fill(
            child: IgnorePointer(
              child: _ScanLineWidget(
                scanLeft: scanLeft,
                scanTop: scanTop,
                scanSize: scanSize,
              ),
            ),
          ),

          // =================================================
          // INSTRUCTION CHIP
          // =================================================

          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
            left: 36,
            right: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'scan_instruction'.tr,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =================================================
          // BOTTOM STATUS CARD
          // =================================================

          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isLoading.value) ...[
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      controller.scanStatus.value,
                      textAlign: TextAlign.center,
                      style: Get.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!controller.isLoading.value) ...[
                      const SizedBox(height: 8),
                      Text(
                        'scan_hint'.tr,
                        textAlign: TextAlign.center,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  static const double _r = 20.0;
  static const double _cornerLen = 38.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double scanSize = size.width * 0.72;

    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2.3),
      width: scanSize,
      height: scanSize,
    );

    // Dark overlay with transparent cutout
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
              RRect.fromRectAndRadius(scanRect, const Radius.circular(_r))),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.58),
    );

    // Corner glow (blurred wide stroke drawn first, under the solid corners)
    final Paint glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Solid corners (L-shaped paths that follow the rounded rect corners)
    final Paint cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final List<Path> cornerPaths = [
      // TOP LEFT
      Path()
        ..moveTo(scanRect.left, scanRect.top + _cornerLen)
        ..lineTo(scanRect.left, scanRect.top + _r)
        ..arcToPoint(Offset(scanRect.left + _r, scanRect.top),
            radius: const Radius.circular(_r), clockwise: true)
        ..lineTo(scanRect.left + _cornerLen, scanRect.top),
      // TOP RIGHT
      Path()
        ..moveTo(scanRect.right - _cornerLen, scanRect.top)
        ..lineTo(scanRect.right - _r, scanRect.top)
        ..arcToPoint(Offset(scanRect.right, scanRect.top + _r),
            radius: const Radius.circular(_r), clockwise: true)
        ..lineTo(scanRect.right, scanRect.top + _cornerLen),
      // BOTTOM RIGHT
      Path()
        ..moveTo(scanRect.right, scanRect.bottom - _cornerLen)
        ..lineTo(scanRect.right, scanRect.bottom - _r)
        ..arcToPoint(Offset(scanRect.right - _r, scanRect.bottom),
            radius: const Radius.circular(_r), clockwise: true)
        ..lineTo(scanRect.right - _cornerLen, scanRect.bottom),
      // BOTTOM LEFT
      Path()
        ..moveTo(scanRect.left + _cornerLen, scanRect.bottom)
        ..lineTo(scanRect.left + _r, scanRect.bottom)
        ..arcToPoint(Offset(scanRect.left, scanRect.bottom - _r),
            radius: const Radius.circular(_r), clockwise: true)
        ..lineTo(scanRect.left, scanRect.bottom - _cornerLen),
    ];

    for (final path in cornerPaths) {
      canvas.drawPath(path, glowPaint);
    }
    for (final path in cornerPaths) {
      canvas.drawPath(path, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) => false;
}

class _ScanLineWidget extends StatefulWidget {
  final double scanLeft;
  final double scanTop;
  final double scanSize;

  const _ScanLineWidget({
    required this.scanLeft,
    required this.scanTop,
    required this.scanSize,
  });

  @override
  State<_ScanLineWidget> createState() => _ScanLineWidgetState();
}

class _ScanLineWidgetState extends State<_ScanLineWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            left: widget.scanLeft + 14,
            top: widget.scanTop + 6 + (widget.scanSize - 12) * _anim.value,
            child: Container(
              width: widget.scanSize - 28,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.6),
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
