import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tamdansers_lv2/screens/student/attendance_scan/attendance_scan_controller.dart';
part 'attendance_scan_binding.dart';

class AttendanceScanView
    extends GetView<
        AttendanceScanController> {
  const AttendanceScanView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.black,

      appBar: AppBar(
        title: const Text(
          'Scan Attendance',
        ),
        backgroundColor:
            Colors.black,
        foregroundColor:
            Colors.white,
      ),

      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller:
                controller
                    .scannerController,

            onDetect: (
              BarcodeCapture capture,
            ) {
              if (capture
                  .barcodes.isEmpty) {
                return;
              }

              final String? token =
                  capture
                      .barcodes
                      .first
                      .rawValue;

              if (token == null) {
                return;
              }

              controller.scanQr(
                token,
              );
            },
          ),

          // Dark overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter:
                    ScannerOverlayPainter(),
              ),
            ),
          ),

          // Instructions
          Positioned(
            left: 20,
            right: 20,
            bottom: 50,
            child: Container(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.black
                    .withOpacity(
                  0.70,
                ),
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Obx(
                () => Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    if (controller
                        .isLoading
                        .value)
                      const Padding(
                        padding:
                            EdgeInsets.only(
                          bottom: 12,
                        ),
                        child:
                            CircularProgressIndicator(
                          color:
                              Colors.white,
                        ),
                      ),

                    Text(
                      controller
                              .isLoading
                              .value
                          ? 'Checking attendance...'
                          : 'Scan the QR code shown by your teacher',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
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

class ScannerOverlayPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint overlayPaint =
        Paint()
          ..color = Colors.black
              .withOpacity(
            0.45,
          );

    final double scanSize =
        size.width * 0.72;

    final Rect scanRect =
        Rect.fromCenter(
      center: Offset(
        size.width / 2,
        size.height / 2.3,
      ),
      width: scanSize,
      height: scanSize,
    );

    final Path background =
        Path()
          ..addRect(
            Rect.fromLTWH(
              0,
              0,
              size.width,
              size.height,
            ),
          );

    final Path hole =
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              scanRect,
              const Radius.circular(
                24,
              ),
            ),
          );

    final Path overlay =
        Path.combine(
      PathOperation.difference,
      background,
      hole,
    );

    canvas.drawPath(
      overlay,
      overlayPaint,
    );

    final Paint borderPaint =
        Paint()
          ..color = Colors.white
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        scanRect,
        const Radius.circular(
          24,
        ),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(
    ScannerOverlayPainter
        oldDelegate,
  ) {
    return false;
  }
}