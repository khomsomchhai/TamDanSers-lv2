import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/services/attendance_service.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/attendance_tab/attendance_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/home_tab/home_tab_view.dart';


class AttendanceScanController extends GetxController {
  final AttendanceService attendanceService = AttendanceService();

  final MobileScannerController scannerController = MobileScannerController();

  final isLoading = false.obs;
  final isScanned = false.obs;

  final locationReady = false.obs;

  final scanStatus =
      'scan_getting_location'.tr.obs;


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
          'scan_checking_location'.tr;

      final bool serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        locationReady.value = false;

        scanStatus.value =
            'location_service_required'.tr;

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
            'location_permission_required'.tr;

        Get.snackbar(
          'location_required'.tr,
          'please_allow_location_permission'.tr,
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
            'enable_location_permission_settings'.tr;

        await _showAppSettingsDialog();

        return;
      }

      // =====================================================
      // READY
      // =====================================================

      locationReady.value = true;

      scanStatus.value =
          'scan_default_status'.tr;

    } catch (error) {
      debugPrint(
        'PREPARE LOCATION ERROR: $error',
      );

      locationReady.value = false;

      scanStatus.value =
          'cannot_access_location'.tr;
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
        'scan_getting_location'.tr;

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
    final String token = rawValue.trim();

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

      scanStatus.value = 'scan_checking_qr'.tr;

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

      scanStatus.value =
          'scan_checking_location'.tr;

      // =====================================================
      // CALL BACKEND
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
      // RESPONSE
      // =====================================================

      final dynamic attendance = response['attendance'];

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
              'scan_recorded'.tr;

      final dynamic distanceValue = response['distance_m'];

      final double? distance =
          distanceValue is num
              ? distanceValue
                  .toDouble()
              : double.tryParse(
                  distanceValue
                          ?.toString() ??
                      '',
                );

      scanStatus.value = 'scan_recorded'.tr;

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

        return 'scan_not_found'.tr;
      }

      if (
          error.response
                  ?.statusCode ==
              403) {

        return 'attendance_scan_forbidden'.tr;
      }

      return error.message ??
          'attendance_scan_failed'.tr;
    }


    // =======================================================
    // NORMAL ERROR
    // =======================================================

    final String originalMessage =
        error.toString();

    final String message = originalMessage.toLowerCase();


    if (
        message.contains(
          'location_service_disabled',
        ) ||
        message.contains(
          'location_not_ready',
        )) {

      return 'please_turn_on_gps'.tr;
    }


    if (
        message.contains(
          'location_permission_denied_forever',
        )) {

      return 'location_permission_denied_forever'.tr;
    }


    if (
        message.contains(
          'location_permission_denied',
        )) {

      return 'location_permission_denied'.tr;
    }


    if (
        message.contains(
          'gps_accuracy_too_low',
        ) ||
        message.contains(
          'not accurate enough',
        )) {

      return 'gps_accuracy_too_low'.tr;
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
            'too_far_from_teacher'.tr,
      );
    }


    if (
        message.contains(
          'qr attendance session not found',
        ) ||
        message.contains(
          '404',
        )) {

      return 'scan_not_found'.tr;
    }


    if (
        message.contains(
          'expired',
        )) {

      return 'scan_expired'.tr;
    }


    // Wrong class
    if (message.contains(
      'not for your class',
    )) {
      return 'scan_wrong_class'.tr;
    }

    // Already recorded
    if (message.contains(
          'attendance already recorded',
        ) ||

        message.contains(
          'already recorded',
        )) {

      return 'attendance_already_recorded'.tr;
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

      return 'cannot_connect_server'.tr;
    }


    return _extractBackendDetail(
      originalMessage,
      fallback:
          'attendance_scan_failed'.tr,
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

  Future<void> _showLocationServiceDialog() async {

    await Get.dialog(
      Dialog(
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
        child: Container(
          padding:
              const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.theme
                .scaffoldBackgroundColor,
            borderRadius:
                BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning
                      .withValues(alpha: 0.15),
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_disabled,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Text(
                'turn_on_location'.tr,
                textAlign:
                    TextAlign.center,
                style: Get.textTheme
                    .titleLarge,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'location_gps_required_message'
                    .tr,
                textAlign:
                    TextAlign.center,
                style: Get.textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Get.theme
                          .colorScheme
                          .onSurface
                          .withValues(
                            alpha: 0.7,
                          ),
                      height: 1.6,
                    ),
              ),
              const SizedBox(
                height: 28,
              ),
              SizedBox(
                width:
                    double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();

                    await Geolocator
                        .openLocationSettings();
                  },
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                        AppColors.warning,
                    padding:
                        const EdgeInsets
                            .symmetric(
                          vertical: 14,
                        ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    textStyle:
                        Get.textTheme
                            .bodyLarge,
                  ),
                  child: Text(
                    'open_settings'.tr,
                    style: Get.textTheme
                        .bodyLarge
                        ?.copyWith(
                          color: Colors
                              .white,
                        ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width:
                    double.infinity,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: TextButton
                      .styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                          vertical: 12,
                        ),
                    textStyle:
                        Get.textTheme
                            .bodyLarge,
                  ),
                  child: Text(
                    'cancel'.tr,
                    style: Get.textTheme
                        .bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible:
          false,
    );
  }


  // =========================================================
  // APP SETTINGS DIALOG
  // =========================================================

  Future<void> _showAppSettingsDialog() async {

    await Get.dialog(
      Dialog(
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
        child: Container(
          padding:
              const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.theme.scaffoldBackgroundColor,
            borderRadius:
                BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info
                      .withValues(alpha: 0.15),
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .location_on_rounded,
                  color: AppColors.info,
                  size: 32,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Text(
                'location_permission_title'
                    .tr,
                textAlign:
                    TextAlign.center,
                style:
                    Get.textTheme
                        .titleLarge,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'location_permission_settings_message'
                    .tr,
                textAlign:
                    TextAlign.center,
                style: Get.textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Get.theme
                          .colorScheme
                          .onSurface
                          .withValues(
                            alpha:
                                0.7,
                          ),
                      height: 1.6,
                    ),
              ),
              const SizedBox(
                height: 28,
              ),
              SizedBox(
                width:
                    double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await Geolocator
                        .openAppSettings();
                  },
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                        AppColors.info,
                    padding:
                        const EdgeInsets
                            .symmetric(
                          vertical: 14,
                        ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    textStyle:
                        Get.textTheme
                            .labelLarge,
                  ),
                  child: Text(
                    'open_settings'.tr,
                    style: Get.textTheme
                        .labelLarge
                        ?.copyWith(
                          color: Colors
                              .white,
                        ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width:
                    double.infinity,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: TextButton
                      .styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                          vertical: 12,
                        ),
                    textStyle:
                        Get.textTheme
                            .labelLarge,
                  ),
                  child: Text(
                    'cancel'.tr,
                    style: Get.textTheme
                        .labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
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

    final Color iconColor =
        alreadyRecorded
            ? AppColors.info
            : AppColors.success;

    await Get.dialog(
      Dialog(
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
        child: Container(
          padding:
              const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Get.theme
                .scaffoldBackgroundColor,
            borderRadius:
                BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor
                      .withValues(alpha: 0.15),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  alreadyRecorded
                      ? Icons
                          .info_outline_rounded
                      : Icons
                          .check_circle_rounded,
                  size: 56,
                  color: iconColor,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                alreadyRecorded
                    ? 'attendance_already_recorded_title'
                        .tr
                    : 'attendance_successful'
                        .tr,
                textAlign:
                    TextAlign.center,
                style: Get.textTheme
                    .headlineSmall
                    ?.copyWith(
                      color: Get.theme
                          .colorScheme
                          .onSurface,
                    ),
              ),
              if (subjectName
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 12,
                ),
                Text(
                  subjectName,
                  style: Get.textTheme
                      .titleMedium
                      ?.copyWith(
                        color: AppColors
                            .primary,
                      ),
                ),
              ],
              const SizedBox(
                height: 14,
              ),
              Text(
                message,
                textAlign:
                    TextAlign.center,
                style: Get.textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Get.theme
                          .colorScheme
                          .onSurface
                          .withValues(
                            alpha: 0.75,
                          ),
                      height: 1.5,
                    ),
              ),
              if (distance != null) ...[
                const SizedBox(
                  height: 16,
                ),
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Get.theme
                        .colorScheme
                        .surface,
                    borderRadius:
                        BorderRadius
                            .circular(12),
                    border: Border.all(
                      color: Get.theme
                          .dividerColor,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Icon(
                        Icons
                            .straighten_rounded,
                        size: 18,
                        color:
                            AppColors
                                .primary,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '${'distance_from_teacher'.tr}: ${distance.toStringAsFixed(1)} m',
                        style: Get
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight
                                      .w600,
                              color: Get
                                  .theme
                                  .colorScheme
                                  .onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(
                height: 28,
              ),
              SizedBox(
                width:
                    double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Dialog
                    Get.back();

                    // Scanner screen
                    Get.back(
                      result: true,
                    );
                  },
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                        iconColor,
                    padding:
                        const EdgeInsets
                            .symmetric(
                          vertical: 14,
                        ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(12),
                    ),
                    textStyle:
                        Get.textTheme
                            .bodyLarge,
                  ),
                  child: Text(
                    'ok'.tr,
                    style: Get.textTheme
                        .bodyLarge
                        ?.copyWith(
                          color: Colors
                              .white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }


  @override
  void onClose() {
    scannerController.dispose();

    super.onClose();
  }
}