import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tamdansers_lv2/core/api/services/attendance_service.dart';

class AttendanceScanController
    extends GetxController {
  final AttendanceService attendanceService =
      AttendanceService();

  final MobileScannerController scannerController =
      MobileScannerController();

  final isLoading = false.obs;
  final isScanned = false.obs;

  Future<void> scanQr(
    String rawValue,
  ) async {
    final String token =
        rawValue.trim();

    if (token.isEmpty) {
      return;
    }

    if (isLoading.value ||
        isScanned.value) {
      return;
    }

    try {
      isLoading.value = true;
      isScanned.value = true;

      await scannerController.stop();

      debugPrint(
        'QR VALUE: $token',
      );

      final Map<String, dynamic> response =
          await attendanceService
              .scanAttendance(
        token: token,
      );

      final dynamic attendance =
          response['attendance'];

      final String subjectName =
          attendance is Map
              ? attendance['subject_name']
                      ?.toString() ??
                  ''
              : '';

      final String message =
          response['message']
                  ?.toString() ??
              '';

      Get.snackbar(
        'success'.tr,
        subjectName.isNotEmpty
            ? '${'attendance_recorded_for'.tr} '
                '$subjectName'
            : message.isNotEmpty
                ? message
                : 'attendance_scan_success'.tr,
        snackPosition:
            SnackPosition.BOTTOM,
        backgroundColor:
            Colors.green.shade100,
        colorText:
            Colors.green.shade900,
        duration:
            const Duration(
          seconds: 2,
        ),
      );

      await Future.delayed(
        const Duration(
          milliseconds: 700,
        ),
      );

      Get.back(
        result: true,
      );
    } catch (error) {
      debugPrint(
        'SCAN ATTENDANCE ERROR: '
        '$error',
      );

      isScanned.value = false;

      try {
        await scannerController.start();
      } catch (_) {}

      Get.snackbar(
        'error'.tr,
        _getErrorMessage(
          error,
        ),
        snackPosition:
            SnackPosition.BOTTOM,
        backgroundColor:
            Colors.red.shade100,
        colorText:
            Colors.red.shade900,
        duration:
            const Duration(
          seconds: 3,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _getErrorMessage(
    dynamic error,
  ) {
    final String message =
        error
            .toString()
            .toLowerCase();

    // Wrong QR / token not found
    if (
        message.contains(
          'qr attendance session not found',
        ) ||
        message.contains(
          '404',
        )) {
      return 'attendance_scan_wrong_qr'.tr;
    }

    // Expired QR
    if (
        message.contains(
          'qr code has expired',
        ) ||
        message.contains(
          'expired',
        )) {
      return 'attendance_scan_expired'.tr;
    }

    // Wrong class
    if (
        message.contains(
          'not for your class',
        )) {
      return 'attendance_scan_wrong_class'.tr;
    }

    // Already recorded
    if (
        message.contains(
          'attendance already recorded',
        ) ||
        message.contains(
          'already recorded',
        )) {
      return 'attendance_scan_already'.tr;
    }

    // Forbidden
    if (
        message.contains(
          '403',
        )) {
      return 'attendance_scan_forbidden'.tr;
    }

    // Network error
    if (
        message.contains(
          'connection',
        ) ||
        message.contains(
          'network',
        ) ||
        message.contains(
          'socket',
        )) {
      return 'attendance_scan_network'.tr;
    }

    return 'attendance_scan_invalid'.tr;
  }

  Future<void> restartScanner() async {
    if (isLoading.value) {
      return;
    }

    isScanned.value = false;

    try {
      await scannerController.start();
    } catch (_) {}
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}