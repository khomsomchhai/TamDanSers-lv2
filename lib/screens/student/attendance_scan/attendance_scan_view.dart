import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:tamdansers_lv2/screens/student/attendance_scan/attendance_scan_controller.dart';

part 'attendance_scan_binding.dart';

class AttendanceScanView
    extends GetView<AttendanceScanController> {
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
        title:
            const Text(
          'Scan Attendance',
        ),

        centerTitle: true,

        backgroundColor:
            Colors.black,

        foregroundColor:
            Colors.white,

        elevation: 0,
      ),

      body: Stack(
        children: [
          // =================================================
          // CAMERA
          // =================================================

          Positioned.fill(
            child:
                MobileScanner(
              controller:
                  controller
                      .scannerController,

              onDetect: (
                BarcodeCapture capture,
              ) {
                if (
                    capture
                        .barcodes
                        .isEmpty) {
                  return;
                }

                final String?
                    token =
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
          ),

          // =================================================
          // DARK OVERLAY
          // =================================================

          Positioned.fill(
            child:
                IgnorePointer(
              child:
                  CustomPaint(
                painter:
                    ScannerOverlayPainter(),
              ),
            ),
          ),

          // =================================================
          // TOP INFO
          // =================================================

          Positioned(
            top: 30,
            left: 20,
            right: 20,

            child:
                Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.black
                        .withOpacity(
                  0.60,
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),
              ),

              child:
                  const Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [
                  Icon(
                    Icons
                        .qr_code_scanner_rounded,
                    color:
                        Colors.white,
                    size: 20,
                  ),

                  SizedBox(
                    width: 8,
                  ),

                  Text(
                    'Point camera at teacher QR',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =================================================
          // BOTTOM STATUS
          // =================================================

          Positioned(
            left: 20,
            right: 20,
            bottom: 40,

            child:
                Container(
              padding:
                  const EdgeInsets.all(
                18,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.black
                        .withOpacity(
                  0.80,
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  20,
                ),
              ),

              child:
                  Obx(
                () =>
                    Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    if (
                        controller
                            .isLoading
                            .value) ...[
                      const SizedBox(
                        width: 36,
                        height: 36,

                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              3,
                          color:
                              Colors.white,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),
                    ],

                    Text(
                      controller
                          .scanStatus
                          .value,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,

                        fontSize:
                            16,

                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    if (
                        !controller
                            .isLoading
                            .value) ...[
                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Camera and location are required '
                        'to verify your attendance.',

                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          color:
                              Colors.white
                                  .withOpacity(
                            0.65,
                          ),

                          fontSize:
                              12,
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


// ===========================================================
// SCANNER OVERLAY
// ===========================================================

class ScannerOverlayPainter
    extends CustomPainter {

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint overlayPaint =
        Paint()
          ..color =
              Colors.black
                  .withOpacity(
            0.48,
          );

    final double scanSize =
        size.width *
            0.72;

    final Rect scanRect =
        Rect.fromCenter(
      center:
          Offset(
        size.width / 2,
        size.height / 2.3,
      ),

      width:
          scanSize,

      height:
          scanSize,
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
          ..color =
              Colors.white
          ..style =
              PaintingStyle.stroke
          ..strokeWidth =
              3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        scanRect,

        const Radius.circular(
          24,
        ),
      ),

      borderPaint,
    );

    final Paint cornerPaint =
        Paint()
          ..color =
              Colors.greenAccent
          ..style =
              PaintingStyle.stroke
          ..strokeWidth =
              5
          ..strokeCap =
              StrokeCap.round;

    const double corner =
        30;

    // TOP LEFT
    canvas.drawLine(
      Offset(
        scanRect.left,
        scanRect.top +
            corner,
      ),
      Offset(
        scanRect.left,
        scanRect.top +
            8,
      ),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(
        scanRect.left +
            8,
        scanRect.top,
      ),
      Offset(
        scanRect.left +
            corner,
        scanRect.top,
      ),
      cornerPaint,
    );

    // TOP RIGHT
    canvas.drawLine(
      Offset(
        scanRect.right -
            corner,
        scanRect.top,
      ),
      Offset(
        scanRect.right -
            8,
        scanRect.top,
      ),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(
        scanRect.right,
        scanRect.top +
            8,
      ),
      Offset(
        scanRect.right,
        scanRect.top +
            corner,
      ),
      cornerPaint,
    );

    // BOTTOM LEFT
    canvas.drawLine(
      Offset(
        scanRect.left,
        scanRect.bottom -
            corner,
      ),
      Offset(
        scanRect.left,
        scanRect.bottom -
            8,
      ),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(
        scanRect.left +
            8,
        scanRect.bottom,
      ),
      Offset(
        scanRect.left +
            corner,
        scanRect.bottom,
      ),
      cornerPaint,
    );

    // BOTTOM RIGHT
    canvas.drawLine(
      Offset(
        scanRect.right -
            corner,
        scanRect.bottom,
      ),
      Offset(
        scanRect.right -
            8,
        scanRect.bottom,
      ),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(
        scanRect.right,
        scanRect.bottom -
            corner,
      ),
      Offset(
        scanRect.right,
        scanRect.bottom -
            8,
      ),
      cornerPaint,
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