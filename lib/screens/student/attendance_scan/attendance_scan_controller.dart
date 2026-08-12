import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:tamdansers_lv2/core/api/services/attendance_service.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/attendance_tab/attendance_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/home_tab/home_tab_view.dart';


class AttendanceScanController extends GetxController {
  final AttendanceService attendanceService =
      AttendanceService();

  final MobileScannerController scannerController =
      MobileScannerController();

  final isLoading = false.obs;
  final isScanned = false.obs;

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


  // =========================================================
  // GET CURRENT LOCATION
  // =========================================================

  Future<Position> _getCurrentLocation() async {
    final bool serviceEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'LOCATION_SERVICE_DISABLED',
      );
    }

    LocationPermission permission =
        await Geolocator
            .checkPermission();

    if (
        permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator
              .requestPermission();
    }

    if (
        permission ==
        LocationPermission.denied) {

      throw Exception(
        'LOCATION_PERMISSION_DENIED',
      );
    }

    if (
        permission ==
        LocationPermission.deniedForever) {

      throw Exception(
        'LOCATION_PERMISSION_DENIED_FOREVER',
      );
    }

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
    final String token =
        rawValue.trim();

    if (token.isEmpty) {
      return;
    }

    if (
        isLoading.value ||
        isScanned.value) {

      return;
    }

    try {
      isLoading.value = true;
      isScanned.value = true;

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

      final Position position =
          await _getCurrentLocation();

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

      scanStatus.value =
          'Checking your distance from teacher...';

      // =====================================================
      // CALL BACKEND
      // =====================================================

      final Map<String, dynamic> response =
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
      );

      debugPrint(
        'ATTENDANCE RESPONSE: $response',
      );

      // =====================================================
      // RESPONSE
      // =====================================================

      final dynamic attendance =
          response['attendance'];

      final String subjectName =
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

      final dynamic distanceValue =
          response['distance_m'];

      final double? distance =
          distanceValue is num
              ? distanceValue
                  .toDouble()
              : double.tryParse(
                  distanceValue
                          ?.toString() ??
                      '',
                );

      scanStatus.value =
          'Attendance recorded';

      // =====================================================
      // REFRESH ATTENDANCE TAB
      // =====================================================

      try {
        if (
            Get.isRegistered<
                AttendanceTabViewController>()) {

          await Get.find<
                  AttendanceTabViewController>()
              .fetchAttendance();
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
        if (
            Get.isRegistered<
                HomeTabViewController>()) {

          await Get.find<
                  HomeTabViewController>()
              .refreshHome();
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

      scanStatus.value =
          'Scan the QR code shown by your teacher';

      try {
        await scannerController.start();
      } catch (_) {}

      Get.snackbar(
        'Error',
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
          seconds: 4,
        ),
      );

    } finally {
      isLoading.value = false;
    }
  }


  // =========================================================
  // GET ERROR MESSAGE
  // =========================================================

  String _getErrorMessage(
    dynamic error,
  ) {
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

    final String message =
        originalMessage
            .toLowerCase();


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

      return 'Location permission is permanently denied. '
          'Please enable Location permission in Settings.';
    }


    if (
        message.contains(
          'location_permission_denied',
        )) {

      return 'Please allow Location permission to scan attendance.';
    }


    if (
        message.contains(
          'gps_accuracy_too_low',
        ) ||
        message.contains(
          'not accurate enough',
        )) {

      return 'Your GPS accuracy is too low. '
          'Please enable precise location and try again.';
    }


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
          'qr attendance session not found',
        ) ||
        message.contains(
          '404',
        )) {

      return 'QR attendance session not found.';
    }


    if (
        message.contains(
          'expired',
        )) {

      return 'This QR code has expired. Please scan a new QR.';
    }


    if (
        message.contains(
          'not for your class',
        )) {

      return 'This QR code is not for your class.';
    }


    if (
        message.contains(
          'already recorded',
        )) {

      return 'Attendance already recorded.';
    }


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

      return 'Cannot connect to server. Please check your internet.';
    }


    return _extractBackendDetail(
      originalMessage,
      fallback:
          'Attendance scan failed. Please try again.',
    );
  }


  // =========================================================
  // EXTRACT FASTAPI DETAIL FROM STRING
  // =========================================================

  String _extractBackendDetail(
    String message, {
    required String fallback,
  }) {
    const String detailKey =
        'detail';

    final int detailIndex =
        message
            .toLowerCase()
            .indexOf(
              detailKey,
            );

    if (detailIndex == -1) {
      return fallback;
    }

    String result =
        message.substring(
      detailIndex +
          detailKey.length,
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
  }


  // =========================================================
  // RESTART
  // =========================================================

  Future<void> restartScanner() async {
    if (isLoading.value) {
      return;
    }

    isScanned.value = false;

    scanStatus.value =
        'Scan the QR code shown by your teacher';

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