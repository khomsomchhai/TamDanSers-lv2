import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tamdansers_lv2/core/api/services/attendance_service.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/attendance_tab/attendance_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/home_tab/home_tab_view.dart';

class AttendanceScanController extends GetxController {
  final AttendanceService attendanceService = AttendanceService();

  final MobileScannerController scannerController = MobileScannerController();

  final isLoading = false.obs;
  final isScanned = false.obs;

  final scanStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    scanStatus.value = 'scan_default_status'.tr;
  }

  // =========================================================
  // GET CURRENT LOCATION
  // =========================================================

  Future<Position> _getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'LOCATION_SERVICE_DISABLED',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'LOCATION_PERMISSION_DENIED',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'LOCATION_PERMISSION_DENIED_FOREVER',
      );
    }

    scanStatus.value = 'scan_getting_location'.tr;

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(
          seconds: 15,
        ),
      ),
    );

    debugPrint(
      'STUDENT LAT: ${position.latitude}',
    );

    debugPrint(
      'STUDENT LNG: ${position.longitude}',
    );

    debugPrint(
      'GPS ACCURACY: ${position.accuracy}m',
    );

    return position;
  }

  // =========================================================
  // SCAN QR
  // =========================================================

  Future<void> scanQr(
    String rawValue,
  ) async {
    final String token = rawValue.trim();

    if (token.isEmpty) {
      return;
    }

    if (isLoading.value || isScanned.value) {
      return;
    }

    try {
      isLoading.value = true;
      isScanned.value = true;

      scanStatus.value = 'scan_checking_qr'.tr;

      // Prevent duplicate scans
      await scannerController.stop();

      debugPrint(
        'QR VALUE: $token',
      );

      // =====================================================
      // LOCATION
      // =====================================================

      final Position position = await _getCurrentLocation();

      // Student GPS should be reasonably accurate
      if (position.accuracy > 100) {
        throw Exception(
          'GPS_ACCURACY_TOO_LOW:${position.accuracy}',
        );
      }

      scanStatus.value = 'scan_checking_location'.tr;

      // =====================================================
      // API
      // =====================================================

      final Map<String, dynamic> response =
          await attendanceService.scanAttendance(
        token: token,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      debugPrint(
        'ATTENDANCE RESPONSE: $response',
      );

      // =====================================================
      // RESPONSE DATA
      // =====================================================

      final dynamic attendance = response['attendance'];

      final String subjectName =
          attendance is Map ? attendance['subject_name']?.toString() ?? '' : '';

      final String message = response['message']?.toString() ?? '';

      final dynamic distanceValue = response['distance_m'];

      final double? distance = distanceValue is num
          ? distanceValue.toDouble()
          : double.tryParse(
              distanceValue?.toString() ?? '',
            );

      scanStatus.value = 'scan_recorded'.tr;

      // =====================================================
      // REFRESH ATTENDANCE TAB
      // =====================================================

      try {
        if (Get.isRegistered<AttendanceTabViewController>()) {
          await Get.find<AttendanceTabViewController>().fetchAttendance();
        }
      } catch (error) {
        debugPrint(
          'REFRESH ATTENDANCE ERROR: $error',
        );
      }

      // =====================================================
      // REFRESH HOME
      // =====================================================

      try {
        if (Get.isRegistered<HomeTabViewController>()) {
          await Get.find<HomeTabViewController>().refreshHome();
        }
      } catch (error) {
        debugPrint(
          'REFRESH HOME ERROR: $error',
        );
      }

      Get.forceAppUpdate();

      // =====================================================
      // SUCCESS DIALOG
      // =====================================================

      await _showSuccessDialog(
        message: message,
        subjectName: subjectName,
        distance: distance,
      );
    } catch (error) {
      debugPrint(
        'SCAN ATTENDANCE ERROR: $error',
      );

      isScanned.value = false;

      scanStatus.value = 'scan_default_status'.tr;

      try {
        await scannerController.start();
      } catch (_) {}

      Get.snackbar(
        'error'.tr,
        _getErrorMessage(
          error,
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(
          seconds: 4,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // SUCCESS DIALOG
  // =========================================================

  Future<void> _showSuccessDialog({
    required String message,
    required String subjectName,
    required double? distance,
  }) async {
    final bool alreadyRecorded = message.toLowerCase().contains(
          'already recorded',
        );

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            24,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          24,
          28,
          24,
          22,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // =================================================
            // ICON
            // =================================================

            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: alreadyRecorded
                    ? Colors.blue.shade100
                    : Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                alreadyRecorded
                    ? Icons.check_circle_outline_rounded
                    : Icons.check_rounded,
                size: 48,
                color: alreadyRecorded
                    ? Colors.blue.shade700
                    : Colors.green.shade700,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =================================================
            // TITLE
            // =================================================

            Text(
              alreadyRecorded
                  ? 'Attendance Already Recorded'
                  : 'Attendance Successful',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =================================================
            // SUBJECT
            // =================================================

            if (subjectName.isNotEmpty) ...[
              Text(
                subjectName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],

            // =================================================
            // MESSAGE
            // =================================================

            Text(
              message.isNotEmpty
                  ? message
                  : 'Attendance recorded successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),

            // =================================================
            // DISTANCE
            // =================================================

            if (distance != null) ...[
              const SizedBox(
                height: 16,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      '${distance.toStringAsFixed(1)} m',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(
              height: 26,
            ),

            // =================================================
            // OK BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Close Dialog
                  Get.back();

                  // Close QR scanner
                  // and return to Attendance screen
                  Get.back(
                    result: true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: alreadyRecorded
                      ? Colors.blue.shade600
                      : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // =========================================================
  // ERROR MESSAGE
  // =========================================================

  String _getErrorMessage(
    dynamic error,
  ) {
    final String originalMessage = error.toString();

    final String message = originalMessage.toLowerCase();

    // Location off
    if (message.contains(
      'location_service_disabled',
    )) {
      return 'Please turn on GPS / Location and try again.';
    }

    // Permission denied forever
    if (message.contains(
      'location_permission_denied_forever',
    )) {
      return 'Location permission is permanently denied. '
          'Please enable Location in your phone Settings.';
    }

    // Permission denied
    if (message.contains(
      'location_permission_denied',
    )) {
      return 'Location permission is required for attendance.';
    }

    // GPS accuracy
    if (message.contains(
          'gps_accuracy_too_low',
        ) ||
        message.contains(
          'accuracy is too low',
        ) ||
        message.contains(
          'not accurate enough',
        )) {
      return 'GPS accuracy is too low. '
          'Please enable precise location and try again.';
    }

    // Too far
    if (message.contains(
      'too far from the class',
    )) {
      return _extractBackendDetail(
        originalMessage,
        fallback: 'You are too far from the classroom.',
      );
    }

    // Wrong QR
    if (message.contains(
          'qr attendance session not found',
        ) ||
        message.contains(
          '404',
        )) {
      return 'attendance_scan_wrong_qr'.tr;
    }

    // Expired
    if (message.contains(
          'qr code has expired',
        ) ||
        message.contains(
          'expired',
        )) {
      return 'attendance_scan_expired'.tr;
    }

    // Wrong class
    if (message.contains(
      'not for your class',
    )) {
      return 'attendance_scan_wrong_class'.tr;
    }

    // Already recorded
    if (message.contains(
          'attendance already recorded',
        ) ||
        message.contains(
          'already recorded',
        )) {
      return 'attendance_scan_already'.tr;
    }

    // Network
    if (message.contains(
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

    // Forbidden
    if (message.contains(
      '403',
    )) {
      return _extractBackendDetail(
        originalMessage,
        fallback: 'attendance_scan_forbidden'.tr,
      );
    }

    // Other errors
    return _extractBackendDetail(
      originalMessage,
      fallback: 'attendance_scan_invalid'.tr,
    );
  }

  // =========================================================
  // EXTRACT BACKEND DETAIL
  // =========================================================

  String _extractBackendDetail(
    String message, {
    required String fallback,
  }) {
    const String detailKey = 'detail';

    final int detailIndex = message.toLowerCase().indexOf(
          detailKey,
        );

    if (detailIndex == -1) {
      return fallback;
    }

    String result = message.substring(
      detailIndex + detailKey.length,
    );

    result = result
        .replaceFirst(
          RegExp(
            r'''^[\s:='"]+''',
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r'''[}\]'"]+$''',
          ),
          '',
        )
        .trim();

    if (result.isEmpty) {
      return fallback;
    }

    return result;
  }

  // =========================================================
  // SETTINGS
  // =========================================================

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // =========================================================
  // RESTART SCANNER
  // =========================================================

  Future<void> restartScanner() async {
    if (isLoading.value) {
      return;
    }

    isScanned.value = false;

    scanStatus.value = 'scan_default_status'.tr;

    try {
      await scannerController.start();
    } catch (_) {}
  }

  // =========================================================
  // CLOSE
  // =========================================================

  @override
  void onClose() {
    scannerController.dispose();

    super.onClose();
  }
}
