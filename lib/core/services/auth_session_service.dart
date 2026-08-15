import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/screens/notification/notification_view.dart';

class AuthSessionService {
  AuthSessionService._();

  static final AuthSessionService _instance = AuthSessionService._();

  factory AuthSessionService() => _instance;

  final GetStorage _box = GetStorage();

  CancelToken _activeRequestsToken = CancelToken();

  CancelToken get activeRequestsToken => _activeRequestsToken;

  void resetActiveRequestsToken() {
    _activeRequestsToken = CancelToken();
  }

  void cancelActiveRequests() {
    if (!_activeRequestsToken.isCancelled) {
      _activeRequestsToken.cancel('Session closed');
    }
    _activeRequestsToken = CancelToken();
  }

  bool get hasActiveToken =>
      (_box.read<String>('token') ?? '').toString().trim().isNotEmpty;

  Future<void> clearSessionData({bool navigateToLogin = false}) async {
    cancelActiveRequests();

    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().clearForLogout();
    }

    if (Get.isRegistered<UserController>()) {
      Get.find<UserController>().clearUser();
    }

    await _box.remove('token');
    await _box.remove('role');
    await _box.remove('student_id');
    await _box.remove('parent');
    await _box.remove('students');
    await _box.remove('notificationsCount');
    await _box.remove('deletedNotificationIds');

    if (navigateToLogin && Get.currentRoute != AppRoutes.loginScreen) {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }

  Future<void> logoutAndNavigate() async {
    await clearSessionData(navigateToLogin: true);
  }

  Future<void> handleUnauthorized({bool navigateToLogin = true}) async {
    if (!hasActiveToken && Get.currentRoute == AppRoutes.loginScreen) {
      return;
    }

    await clearSessionData(navigateToLogin: navigateToLogin);
  }
}
