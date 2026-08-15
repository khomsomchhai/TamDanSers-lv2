part of 'login_screen_view.dart';

class LoginScreenViewController extends GetxController {
  // =========================================================
  // TEXT CONTROLLERS
  // =========================================================

  final studentIdCtrl = TextEditingController();
  final parentIdCtrl = TextEditingController();

  final studentPwdCtrl = TextEditingController();
  final parentPwdCtrl = TextEditingController();

  TextEditingController get currentIdCtrl =>
      selectedTab.value == 1
          ? parentIdCtrl
          : studentIdCtrl;

  TextEditingController get currentPwdCtrl =>
      selectedTab.value == 1
          ? parentPwdCtrl
          : studentPwdCtrl;

  // =========================================================
  // FORM
  // =========================================================

  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>();

  // =========================================================
  // STATE
  // =========================================================

  final selectedTab = 0.obs;
  final previousTab = 0.obs;

  final isRemember = false.obs;
  final isHidePwd = true.obs;
  final isLoading = false.obs;
  final isKeyboardOpen = false.obs;

  // =========================================================
  // SERVICES
  // =========================================================

  final AuthServices authService =
      AuthServices();

  final GetStorage box =
      GetStorage();

  bool _hasAppliedRouteArgs = false;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();

    _applyRouteArguments();
  }

  // =========================================================
  // ROUTE ARGUMENTS
  // =========================================================

  void _applyRouteArguments() {
    if (_hasAppliedRouteArgs) {
      return;
    }

    _hasAppliedRouteArgs = true;

    final args =
        Get.arguments as Map<String, dynamic>?;

    final dynamic defaultTab =
        args?['defaultTab'];

    if (defaultTab is int &&
        defaultTab >= 0 &&
        defaultTab < 2) {
      selectedTab.value =
          defaultTab;

      previousTab.value =
          defaultTab;
    }
  }

  // =========================================================
  // CHANGE TAB
  // =========================================================

  void changeTab(int index) {
    if (selectedTab.value == index) {
      return;
    }

    previousTab.value =
        selectedTab.value;

    selectedTab.value =
        index;
  }

  // =========================================================
  // KEYBOARD
  // =========================================================

  void updateKeyboard(
    BuildContext context,
  ) {
    isKeyboardOpen.value =
        MediaQuery.of(context)
                .viewInsets
                .bottom >
            0;
  }

  // =========================================================
  // PASSWORD VISIBILITY
  // =========================================================

  void togglePwd() {
    isHidePwd.value =
        !isHidePwd.value;
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ??
        false)) {
      CustomSnackbar.error(
        'please_fill_required'.tr,
      );

      return;
    }

    try {
      isLoading.value = true;

      // =====================================================
      // 1. LOGIN REQUEST
      // =====================================================

      final Map<String, dynamic> response =
          selectedTab.value == 1
              ? await authService
                  .loginParentService(
                  studentCode:
                      currentIdCtrl.text.trim(),
                  password:
                      currentPwdCtrl.text,
                )
              : await authService
                  .loginService(
                  loginId:
                      currentIdCtrl.text.trim(),
                  password:
                      currentPwdCtrl.text,
                );

      debugPrint(
        'LOGIN SUCCESS',
      );

      // =====================================================
      // 2. ACCESS TOKEN
      // =====================================================

      final String token =
          response['access_token']
                  ?.toString()
                  .trim() ??
              '';

      final String role =
          response['role']
                  ?.toString()
                  .trim() ??
              '';

      if (token.isEmpty) {
        CustomSnackbar.error(
          'login_failed'.tr,
        );

        return;
      }

      if (role.isEmpty) {
        CustomSnackbar.error(
          'unknown_user_role'.tr,
        );

        return;
      }

      debugPrint(
        'LOGIN ROLE: $role',
      );

      // =====================================================
      // 3. SAVE AUTH TOKEN FIRST
      //
      // IMPORTANT:
      // FCM request needs this JWT.
      // =====================================================

      await box.write(
        'token',
        token,
      );

      await box.write(
        'role',
        role,
      );

      debugPrint(
        'AUTH TOKEN SAVED',
      );

      // =====================================================
      // 4. CLEAR OLD ACCOUNT-SPECIFIC STATE
      // =====================================================

      await _clearPreviousAccountData(
        newRole: role,
      );

      // =====================================================
      // 5. SAVE CURRENT ACCOUNT DATA
      // =====================================================

      if (role == 'parent') {
        await _saveParentData(
          response,
        );
      } else if (role == 'student') {
        await _saveStudentData(
          response,
        );
      }

      // =====================================================
      // 6. SAVE FCM TOKEN
      //
      // IMPORTANT:
      // Do this BEFORE navigating.
      // =====================================================

      await _saveFcmToken();

      // =====================================================
      // 7. LOAD PROFILE
      // =====================================================

      await _loadProfile();

      // =====================================================
      // 8. NAVIGATE LAST
      // =====================================================

      _navigateByRole(
        role,
      );
    } on DioException catch (e) {
      debugPrint(
        'LOGIN DIO ERROR: '
        '${e.response?.data ?? e.message}',
      );

      CustomSnackbar.error(
        handleDioException(e),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'LOGIN ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      CustomSnackbar.error(
        'something_went_wrong_retry'.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // CLEAR PREVIOUS ACCOUNT DATA
  // =========================================================

  Future<void> _clearPreviousAccountData({
    required String newRole,
  }) async {
    // Clear notification controller memory from
    // previous login if it still exists.
    if (Get.isRegistered<
        NotificationController>()) {
      Get.find<NotificationController>()
          .clearForLogout();
    }

    // Parent-only data should not remain
    // when student logs in.
    if (newRole != 'parent') {
      await box.remove(
        'parent',
      );

      await box.remove(
        'students',
      );
    }

    // Student-only data should not remain
    // when parent logs in.
    if (newRole != 'student') {
      await box.remove(
        'student_id',
      );
    }
  }

  // =========================================================
  // SAVE STUDENT DATA
  // =========================================================

  Future<void> _saveStudentData(
    Map<String, dynamic> response,
  ) async {
    final dynamic profileData =
        response['profile'];

    if (profileData is! Map) {
      debugPrint(
        'STUDENT PROFILE NOT FOUND IN LOGIN RESPONSE',
      );

      return;
    }

    final dynamic studentId =
        profileData['id'] ??
        profileData['student_id'];

    if (studentId == null) {
      debugPrint(
        'STUDENT ID NOT FOUND',
      );

      return;
    }

    final int? parsedId =
        int.tryParse(
      studentId.toString(),
    );

    if (parsedId == null) {
      debugPrint(
        'INVALID STUDENT ID: $studentId',
      );

      return;
    }

    await box.write(
      'student_id',
      parsedId,
    );

    debugPrint(
      'STUDENT ID SAVED: $parsedId',
    );
  }

  // =========================================================
  // SAVE PARENT DATA
  // =========================================================

  Future<void> _saveParentData(
    Map<String, dynamic> response,
  ) async {
    final dynamic parentData =
        response['parent'];

    final dynamic studentsData =
        response['students'];

    await box.remove(
      'parent',
    );

    await box.remove(
      'students',
    );

    if (parentData != null) {
      await box.write(
        'parent',
        parentData,
      );
    }

    if (studentsData is! List) {
      debugPrint(
        'PARENT STUDENTS IS NOT A LIST',
      );

      await box.write(
        'students',
        <Map<String, dynamic>>[],
      );

      return;
    }

    final List<Map<String, dynamic>>
        students = studentsData
            .whereType<Map>()
            .map(
              (item) =>
                  Map<String, dynamic>.from(
                item,
              ),
            )
            .toList();

    await box.write(
      'students',
      students,
    );

    debugPrint(
      'PARENT STUDENTS SAVED: '
      '${students.length}',
    );
  }

  // =========================================================
  // SAVE FCM TOKEN
  // =========================================================

  Future<void> _saveFcmToken() async {
    try {
      // =====================================================
      // CHECK JWT
      // =====================================================

      final String authToken =
          box
                  .read('token')
                  ?.toString()
                  .trim() ??
              '';

      debugPrint(
        'AUTH TOKEN EXISTS: '
        '${authToken.isNotEmpty}',
      );

      if (authToken.isEmpty) {
        debugPrint(
          'SKIP FCM: AUTH TOKEN IS EMPTY',
        );

        return;
      }

      // =====================================================
      // REQUEST NOTIFICATION PERMISSION
      // =====================================================

      final NotificationSettings settings =
          await FirebaseMessaging.instance
              .requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'FCM PERMISSION: '
        '${settings.authorizationStatus}',
      );

      // =====================================================
      // GET FIREBASE TOKEN
      // =====================================================

      final String? fcmToken =
          await FirebaseMessaging.instance
              .getToken();

      debugPrint(
        'FCM TOKEN EXISTS: '
        '${fcmToken != null && fcmToken.isNotEmpty}',
      );

      // For debugging only.
      debugPrint(
        'FCM TOKEN VALUE: $fcmToken',
      );

      if (fcmToken == null ||
          fcmToken.isEmpty) {
        debugPrint(
          'SKIP FCM: FIREBASE TOKEN IS EMPTY',
        );

        return;
      }

      // =====================================================
      // SEND TOKEN TO BACKEND
      // =====================================================

      final dynamic response =
          await authService.saveFcmToken(
        fcmToken: fcmToken,
      );

      debugPrint(
        'SAVE FCM RESPONSE: $response',
      );

      debugPrint(
        'FCM TOKEN SAVED SUCCESSFULLY',
      );
    } on DioException catch (e) {
      debugPrint(
        'SAVE FCM STATUS: '
        '${e.response?.statusCode}',
      );

      debugPrint(
        'SAVE FCM RESPONSE: '
        '${e.response?.data}',
      );

      debugPrint(
        'SAVE FCM URL: '
        '${e.requestOptions.uri}',
      );

      debugPrint(
        'SAVE FCM REQUEST HEADERS: '
        '${e.requestOptions.headers}',
      );

      // FCM failure should not stop login.
    } catch (e, stackTrace) {
      debugPrint(
        'SAVE FCM TOKEN ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      // FCM failure should not stop login.
    }
  }

  // =========================================================
  // LOAD PROFILE
  // =========================================================

  Future<void> _loadProfile() async {
    try {
      if (!Get.isRegistered<
          UserController>()) {
        debugPrint(
          'USER CONTROLLER IS NOT REGISTERED',
        );

        return;
      }

      await Get.find<UserController>()
          .getProfile();

      debugPrint(
        'PROFILE LOADED SUCCESSFULLY',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'GET PROFILE ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // =========================================================
  // NAVIGATE
  // =========================================================

  void _navigateByRole(
    String role,
  ) {
    switch (role) {
      case 'student':
        Get.offAllNamed(
          AppRoutes.studentDashboard,
        );
        break;

      case 'parent':
        Get.offAllNamed(
          AppRoutes.parentDashboard,
        );
        break;

      default:
        CustomSnackbar.error(
          'unknown_user_role'.tr,
        );
    }
  }

  // =========================================================
  // CLOSE
  // =========================================================

  @override
  void onClose() {
    studentIdCtrl.dispose();
    parentIdCtrl.dispose();

    studentPwdCtrl.dispose();
    parentPwdCtrl.dispose();

    super.onClose();
  }
}