import 'package:dio/dio.dart';
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

<<<<<<< HEAD
  final locationReady = false.obs;

  final scanStatus =
      'Preparing location...'.obs;


  // =========================================================
  // SCREEN OPEN
  // =========================================================

  @override
  void onReady() {
    super.onReady();

    prepareLocation();
  }


  // =========================================================
  // PREPARE LOCATION
  //
  // Called immediately when Scan screen opens.
  // Android will show permission popup if permission
  // has not been granted/denied before.
  // =========================================================

  Future<void> prepareLocation() async {
    try {
      scanStatus.value =
          'Checking location permission...';

      final bool serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        locationReady.value = false;

        scanStatus.value =
            'Please turn on GPS / Location';

        await _showLocationServiceDialog();

        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      // =====================================================
      // ASK PERMISSION
      // =====================================================

      if (
          permission ==
          LocationPermission.denied) {

        permission =
            await Geolocator
                .requestPermission();
      }

      // =====================================================
      // USER DENIED
      // =====================================================

      if (
          permission ==
          LocationPermission.denied) {

        locationReady.value = false;

        scanStatus.value =
            'Location permission is required';

        Get.snackbar(
          'Location Required',
          'Please allow location permission to scan attendance.',
          snackPosition:
              SnackPosition.BOTTOM,
          backgroundColor:
              Colors.orange.shade100,
          colorText:
              Colors.orange.shade900,
        );

        return;
      }

      // =====================================================
      // DENIED FOREVER
      // =====================================================

      if (
          permission ==
          LocationPermission.deniedForever) {

        locationReady.value = false;

        scanStatus.value =
            'Enable Location permission in Settings';

        await _showAppSettingsDialog();

        return;
      }

      // =====================================================
      // READY
      // =====================================================

      locationReady.value = true;

      scanStatus.value =
          'Scan the QR code shown by your teacher';

    } catch (error) {
      debugPrint(
        'PREPARE LOCATION ERROR: $error',
      );

      locationReady.value = false;

      scanStatus.value =
          'Cannot access location';
    }
  }

=======
  final scanStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    scanStatus.value = 'scan_default_status'.tr;
  }
>>>>>>> main

  // =========================================================
  // GET CURRENT LOCATION
  // =========================================================

  Future<Position> _getCurrentLocation() async {
<<<<<<< HEAD
    final bool serviceEnabled =
        await Geolocator
            .isLocationServiceEnabled();
=======
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
>>>>>>> main

    if (!serviceEnabled) {
      throw Exception(
        'LOCATION_SERVICE_DISABLED',
      );
    }

<<<<<<< HEAD
    LocationPermission permission =
        await Geolocator
            .checkPermission();

    if (
        permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator
              .requestPermission();
=======
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
>>>>>>> main
    }

    if (
        permission ==
        LocationPermission.denied) {

      throw Exception(
        'LOCATION_PERMISSION_DENIED',
      );
    }

<<<<<<< HEAD
    if (
        permission ==
        LocationPermission.deniedForever) {

=======
    if (permission == LocationPermission.deniedForever) {
>>>>>>> main
      throw Exception(
        'LOCATION_PERMISSION_DENIED_FOREVER',
      );
    }

<<<<<<< HEAD
    scanStatus.value =
        'Getting your current location...';

    final Position position =
        await Geolocator
            .getCurrentPosition(
      locationSettings:
          const LocationSettings(
        accuracy:
            LocationAccuracy.high,

        timeLimit:
            Duration(
          seconds: 20,
=======
    scanStatus.value = 'scan_getting_location'.tr;

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(
          seconds: 15,
>>>>>>> main
        ),
      ),
    );

    debugPrint(
      '================================',
    );

    debugPrint(
      'STUDENT LAT: ${position.latitude}',
    );

    debugPrint(
      'STUDENT LNG: ${position.longitude}',
    );

    debugPrint(
      'STUDENT GPS ACCURACY: '
      '${position.accuracy}m',
    );

    debugPrint(
      '================================',
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

<<<<<<< HEAD
    if (
        isLoading.value ||
        isScanned.value) {

=======
    if (isLoading.value || isScanned.value) {
>>>>>>> main
      return;
    }

    try {
      isLoading.value = true;
      isScanned.value = true;

<<<<<<< HEAD
=======
      scanStatus.value = 'scan_checking_qr'.tr;

      // Prevent duplicate scans
>>>>>>> main
      await scannerController.stop();

      debugPrint(
        'QR TOKEN: $token',
      );

      // =====================================================
      // MAKE SURE LOCATION IS READY
      // =====================================================

      if (!locationReady.value) {
        await prepareLocation();

        if (!locationReady.value) {
          throw Exception(
            'LOCATION_NOT_READY',
          );
        }
      }

      // =====================================================
      // GET STUDENT LOCATION
      // =====================================================

      final Position position = await _getCurrentLocation();

      // =====================================================
      // STUDENT GPS ACCURACY
      // =====================================================

      if (
          position.accuracy >
          100) {

        throw Exception(
          'GPS_ACCURACY_TOO_LOW:'
          '${position.accuracy}',
        );
      }

<<<<<<< HEAD
      scanStatus.value =
          'Checking your distance from teacher...';
=======
      scanStatus.value = 'scan_checking_location'.tr;
>>>>>>> main

      // =====================================================
      // CALL BACKEND
      // =====================================================

      final Map<String, dynamic> response =
<<<<<<< HEAD
          await attendanceService
              .scanAttendance(
        token:
            token,

        latitude:
            position.latitude,

        longitude:
            position.longitude,

        accuracy:
            position.accuracy,
=======
          await attendanceService.scanAttendance(
        token: token,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
>>>>>>> main
      );

      debugPrint(
        'ATTENDANCE RESPONSE: $response',
      );

      // =====================================================
      // RESPONSE
      // =====================================================

      final dynamic attendance = response['attendance'];

      final String subjectName =
<<<<<<< HEAD
          attendance is Map
              ? attendance[
                            'subject_name']
                        ?.toString() ??
                    ''
              : '';

      final String message =
          response['message']
                  ?.toString() ??
              'Attendance recorded successfully';
=======
          attendance is Map ? attendance['subject_name']?.toString() ?? '' : '';

      final String message = response['message']?.toString() ?? '';
>>>>>>> main

      final dynamic distanceValue = response['distance_m'];

<<<<<<< HEAD
      final double? distance =
          distanceValue is num
              ? distanceValue
                  .toDouble()
              : double.tryParse(
                  distanceValue
                          ?.toString() ??
                      '',
                );
=======
      final double? distance = distanceValue is num
          ? distanceValue.toDouble()
          : double.tryParse(
              distanceValue?.toString() ?? '',
            );
>>>>>>> main

      scanStatus.value = 'scan_recorded'.tr;

      // =====================================================
      // REFRESH ATTENDANCE TAB
      // =====================================================

      try {
<<<<<<< HEAD
        if (
            Get.isRegistered<
                AttendanceTabViewController>()) {

          await Get.find<
                  AttendanceTabViewController>()
              .fetchAttendance();
=======
        if (Get.isRegistered<AttendanceTabViewController>()) {
          await Get.find<AttendanceTabViewController>().fetchAttendance();
>>>>>>> main
        }
      } catch (error) {
        debugPrint(
          'REFRESH ATTENDANCE ERROR: '
          '$error',
        );
      }

      // =====================================================
      // REFRESH HOME
      // =====================================================

      try {
<<<<<<< HEAD
        if (
            Get.isRegistered<
                HomeTabViewController>()) {

          await Get.find<
                  HomeTabViewController>()
              .refreshHome();
=======
        if (Get.isRegistered<HomeTabViewController>()) {
          await Get.find<HomeTabViewController>().refreshHome();
>>>>>>> main
        }
      } catch (error) {
        debugPrint(
          'REFRESH HOME ERROR: '
          '$error',
        );
      }

      // =====================================================
      // SUCCESS
      // =====================================================

      await _showSuccessDialog(
        message:
            message,

        subjectName:
            subjectName,

        distance:
            distance,
      );

    } catch (error) {
      debugPrint(
        '================================',
      );

      debugPrint(
        'SCAN ATTENDANCE ERROR:',
      );

      debugPrint(
        error.toString(),
      );

      debugPrint(
        '================================',
      );

      isScanned.value = false;

      scanStatus.value = 'scan_default_status'.tr;

      try {
        await scannerController.start();
      } catch (_) {}

      Get.snackbar(
        'Error',
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

<<<<<<< HEAD
=======
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
>>>>>>> main

  // =========================================================
  // GET ERROR MESSAGE
  // =========================================================

  String _getErrorMessage(
    dynamic error,
  ) {
<<<<<<< HEAD
    // =======================================================
    // DIO / FASTAPI ERROR
    // =======================================================

    if (error is DioException) {
      final dynamic data =
          error.response?.data;

      debugPrint(
        'DIO STATUS: '
        '${error.response?.statusCode}',
      );

      debugPrint(
        'DIO DATA: $data',
      );

      if (data is Map) {
        final dynamic detail =
            data['detail'];

        if (detail != null) {
          return detail.toString();
        }

        final dynamic message =
            data['message'];

        if (message != null) {
          return message.toString();
        }
      }

      if (data is String &&
          data.trim().isNotEmpty) {

        return data;
      }

      if (
          error.response
                  ?.statusCode ==
              404) {

        return 'QR attendance session not found.';
      }

      if (
          error.response
                  ?.statusCode ==
              403) {

        return 'You are not allowed to scan this attendance.';
      }

      return error.message ??
          'Attendance scan failed.';
    }


    // =======================================================
    // NORMAL ERROR
    // =======================================================

    final String originalMessage =
        error.toString();
=======
    final String originalMessage = error.toString();
>>>>>>> main

    final String message = originalMessage.toLowerCase();

<<<<<<< HEAD

    if (
        message.contains(
          'location_service_disabled',
        ) ||
        message.contains(
          'location_not_ready',
        )) {

      return 'Please turn on GPS / Location and try again.';
    }


    if (
        message.contains(
          'location_permission_denied_forever',
        )) {

=======
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
>>>>>>> main
      return 'Location permission is permanently denied. '
          'Please enable Location permission in Settings.';
    }

<<<<<<< HEAD

    if (
        message.contains(
          'location_permission_denied',
        )) {

      return 'Please allow Location permission to scan attendance.';
    }


    if (
        message.contains(
=======
    // Permission denied
    if (message.contains(
      'location_permission_denied',
    )) {
      return 'Location permission is required for attendance.';
    }

    // GPS accuracy
    if (message.contains(
>>>>>>> main
          'gps_accuracy_too_low',
        ) ||
        message.contains(
          'not accurate enough',
        )) {

      return 'Your GPS accuracy is too low. '
          'Please enable precise location and try again.';
    }

<<<<<<< HEAD

    if (
        message.contains(
          'too far from teacher',
        ) ||
        message.contains(
          'too far from the class',
        )) {

      return _extractBackendDetail(
        originalMessage,
        fallback:
            'You are too far from the teacher.',
      );
    }


    if (
        message.contains(
=======
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
>>>>>>> main
          'qr attendance session not found',
        ) ||
        message.contains(
          '404',
        )) {

      return 'QR attendance session not found.';
    }

<<<<<<< HEAD

    if (
=======
    // Expired
    if (message.contains(
          'qr code has expired',
        ) ||
>>>>>>> main
        message.contains(
          'expired',
        )) {

      return 'This QR code has expired. Please scan a new QR.';
    }

<<<<<<< HEAD

    if (
        message.contains(
          'not for your class',
        )) {

      return 'This QR code is not for your class.';
    }


    if (
=======
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
>>>>>>> main
        message.contains(
          'already recorded',
        )) {

      return 'Attendance already recorded.';
    }

<<<<<<< HEAD

    if (
        message.contains(
=======
    // Network
    if (message.contains(
>>>>>>> main
          'connection',
        ) ||
        message.contains(
          'network',
        ) ||
        message.contains(
          'socket',
        )) {

      return 'Cannot connect to server. Please check your internet.';
    }

<<<<<<< HEAD
=======
    // Forbidden
    if (message.contains(
      '403',
    )) {
      return _extractBackendDetail(
        originalMessage,
        fallback: 'attendance_scan_forbidden'.tr,
      );
    }
>>>>>>> main

    return _extractBackendDetail(
      originalMessage,
<<<<<<< HEAD
      fallback:
          'Attendance scan failed. Please try again.',
=======
      fallback: 'attendance_scan_invalid'.tr,
>>>>>>> main
    );
  }


  // =========================================================
  // EXTRACT FASTAPI DETAIL FROM STRING
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
  // LOCATION SERVICE DIALOG
  // =========================================================

<<<<<<< HEAD
  Future<void>
      _showLocationServiceDialog() async {

    await Get.dialog(
      AlertDialog(
        title:
            const Text(
          'Turn On Location',
        ),

        content:
            const Text(
          'Location/GPS must be turned on before you can scan attendance.',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child:
                const Text(
              'Cancel',
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              Get.back();

              await Geolocator
                  .openLocationSettings();
            },

            child:
                const Text(
              'Open Settings',
            ),
          ),
        ],
      ),
      barrierDismissible:
          false,
    );
  }


  // =========================================================
  // APP SETTINGS DIALOG
  // =========================================================

  Future<void>
      _showAppSettingsDialog() async {

    await Get.dialog(
      AlertDialog(
        title:
            const Text(
          'Location Permission',
        ),

        content:
            const Text(
          'Please allow Location permission for TamDanSers in Settings.',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child:
                const Text(
              'Cancel',
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              Get.back();

              await Geolocator
                  .openAppSettings();
            },

            child:
                const Text(
              'Open Settings',
            ),
          ),
        ],
      ),
      barrierDismissible:
          false,
    );
=======
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
>>>>>>> main
  }


  // =========================================================
  // RESTART
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
  // SUCCESS DIALOG
  // =========================================================

  Future<void> _showSuccessDialog({
    required String message,
    required String subjectName,
    required double? distance,
  }) async {

    final bool alreadyRecorded =
        message
            .toLowerCase()
            .contains(
              'already recorded',
            );

    await Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            24,
          ),
        ),

        content:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons
                  .check_circle_rounded,

              size:
                  80,

              color:
                  alreadyRecorded
                      ? Colors.blue
                      : Colors.green,
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              alreadyRecorded
                  ? 'Attendance Already Recorded'
                  : 'Attendance Successful',

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize:
                    20,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            if (
                subjectName
                    .isNotEmpty) ...[
              const SizedBox(
                height:
                    10,
              ),

              Text(
                subjectName,

                style:
                    const TextStyle(
                  fontSize:
                      17,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(
              height:
                  10,
            ),

            Text(
              message,

              textAlign:
                  TextAlign.center,
            ),

            if (distance != null) ...[
              const SizedBox(
                height:
                    12,
              ),

              Text(
                'Distance from teacher: '
                '${distance.toStringAsFixed(1)} m',

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(
              height:
                  20,
            ),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
                onPressed: () {
                  // Dialog
                  Get.back();

                  // Scanner screen
                  Get.back(
                    result:
                        true,
                  );
                },

                child:
                    const Text(
                  'OK',
                ),
              ),
            ),
          ],
        ),
      ),

      barrierDismissible:
          false,
    );
  }


  @override
  void onClose() {
    scannerController.dispose();

    super.onClose();
  }
}
