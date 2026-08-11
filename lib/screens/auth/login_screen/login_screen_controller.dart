part of 'login_screen_view.dart';

class LoginScreenViewController extends GetxController {
  final studentIdCtrl = TextEditingController();
  final parentIdCtrl = TextEditingController();
  final studentPwdCtrl = TextEditingController();
  final parentPwdCtrl = TextEditingController();

  TextEditingController get currentIdCtrl =>
      selectedTab.value == 1 ? parentIdCtrl : studentIdCtrl;

  TextEditingController get currentPwdCtrl =>
      selectedTab.value == 1 ? parentPwdCtrl : studentPwdCtrl;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final selectedTab = 0.obs;
  final previousTab = 0.obs;

  final isRemember = false.obs;
  final isHidePwd = true.obs;
  final isLoading = false.obs;
  final isKeyboardOpen = false.obs;

  final AuthServices authService = AuthServices();
  final GetStorage box = GetStorage();

  void changeTab(int index) {
    if (selectedTab.value == index) return;

    previousTab.value = selectedTab.value;
    selectedTab.value = index;
  }

  void updateKeyboard(BuildContext context) {
    isKeyboardOpen.value = MediaQuery.of(context).viewInsets.bottom > 0;
  }

  void togglePwd() {
    isHidePwd.value = !isHidePwd.value;
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      CustomSnackbar.error(
        'please_fill_required'.tr,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = selectedTab.value == 1
          ? await authService.loginParentService(
              studentCode: currentIdCtrl.text.trim(),
              password: currentPwdCtrl.text,
            )
          : await authService.loginService(
              loginId: currentIdCtrl.text.trim(),
              password: currentPwdCtrl.text,
            );

      // debugPrint(
      //   'LOGIN RESPONSE: $response',
      // );

      final String token = response['access_token']?.toString().trim() ?? '';

      final String role = response['role']?.toString().trim() ?? '';

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

      await box.write(
        'token',
        token,
      );

      await box.write(
        'role',
        role,
      );

      if (role == 'parent') {
        await _saveParentData(
          response,
        );
      } else {
        await box.remove(
          'parent',
        );

        await box.remove(
          'students',
        );
      }

      // debugPrint(
      //   'NAVIGATING TO ROLE: $role',
      // );

      _navigateByRole(
        role,
      );

      // Run in background after navigation.
      _loadProfile();
      _saveFcmToken();
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

      debugPrint(
        'LOGIN STACK TRACE: '
        '$stackTrace',
      );

      CustomSnackbar.error(
        'something_went_wrong_retry'.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveParentData(
    Map<String, dynamic> response,
  ) async {
    final dynamic parentData = response['parent'];
    final dynamic studentsData = response['students'];

    await box.remove('parent');
    await box.remove('students');

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

    final List<Map<String, dynamic>> students =
        studentsData.map<Map<String, dynamic>>((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();

    await box.write(
      'students',
      students,
    );

    // debugPrint(
    //   'SAVED STUDENTS COUNT: ${students.length}',
    // );
  }

  void _navigateByRole(String role) {
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

  Future<void> _loadProfile() async {
    try {
      if (!Get.isRegistered<UserController>()) {
        debugPrint(
          'USER CONTROLLER IS NOT REGISTERED',
        );
        return;
      }

      await Get.find<UserController>().getProfile();

      debugPrint(
        'PROFILE LOADED SUCCESSFULLY',
      );
    } catch (e) {
      debugPrint(
        'GET PROFILE ERROR: $e',
      );
    }
  }

  Future<void> _saveFcmToken() async {
    try {
      final String authToken = box.read('token')?.toString().trim() ?? '';

      if (authToken.isEmpty) {
        debugPrint(
          'SKIP FCM: AUTH TOKEN IS EMPTY',
        );
        return;
      }

      await FirebaseMessaging.instance.requestPermission();

      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      // debugPrint(
      //   'FCM TOKEN: $fcmToken',
      // );

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint(
          'SKIP FCM: FIREBASE TOKEN IS EMPTY',
        );
        return;
      }

      await authService.saveFcmToken(
        fcmToken: fcmToken,
      );

      debugPrint(
        'FCM TOKEN SAVED SUCCESSFULLY',
      );
    } on DioException catch (e) {
      debugPrint(
        'SAVE FCM STATUS: ${e.response?.statusCode}',
      );

      // debugPrint(
      //   'SAVE FCM RESPONSE: ${e.response?.data}',
      // );

      // Do not rethrow. FCM must not block or close the app.
    } catch (e) {
      debugPrint(
        'SAVE FCM TOKEN ERROR: $e',
      );
    }
  }

  @override
  void onClose() {
    studentIdCtrl.dispose();
    parentIdCtrl.dispose();
    studentPwdCtrl.dispose();
    parentPwdCtrl.dispose();
    super.onClose();
  }
}