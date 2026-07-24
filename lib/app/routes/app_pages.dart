import 'package:get/route_manager.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/screens/auth/change_password_screen/change_password_screen_view.dart';
import 'package:tamdansers_lv2/screens/auth/forget_password_screen/forget_password_screen_view.dart';
import 'package:tamdansers_lv2/screens/auth/login_screen/login_screen_view.dart';
import 'package:tamdansers_lv2/screens/auth/register_parent_screen/register_parent_screen_view.dart';
import 'package:tamdansers_lv2/screens/auth/reset_password_screen/reset_password_screen_view.dart';
import 'package:tamdansers_lv2/screens/auth/splash_screen/splash_screen_view.dart';
import 'package:tamdansers_lv2/screens/notification/notification_view.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_dashboard_view.dart';
import 'package:tamdansers_lv2/screens/student/ask_permission_screen/ask_permission_screen_view.dart';
import 'package:tamdansers_lv2/screens/student/homework/homework_view.dart';
import 'package:tamdansers_lv2/screens/student/result_screen/result_screen_view.dart';
import 'package:tamdansers_lv2/screens/student/schedule_screen/schedule_screen_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/student_dashboard_view.dart';

class AppPages {
  static final List<GetPage> getPages = [
    //Auth
    GetPage(
        name: AppRoutes.splashScreen,
        page: () => SplashScreenView(),
        binding: SplashScreenViewBinding(),
        transition: Transition.fadeIn),
    GetPage(
      name: AppRoutes.loginScreen,
      page: () => LoginScreenView(),
      binding: LoginScreenViewBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.forgetPasswordScreen,
      page: () => const ForgetPasswordScreenView(),
      binding: ForgetPasswordScreenViewBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.resetPasswordScreen,
      page: () => const ResetPasswordScreenView(),
      binding: ResetPasswordScreenViewBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.changePasswordScreen,
      page: () => const ChangePasswordScreenView(),
      binding: ChangePasswordScreenViewBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.registerParentScreen,
      page: () => const RegisterParentScreenView(),
      binding: RegisterParentScreenViewBinding(),
      transition: Transition.rightToLeft,
    ),

    ///////////////////////////
    //Student
    GetPage(
        name: AppRoutes.studentDashboard,
        page: () => StudentDashboardView(),
        binding: StudentDashboardViewBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: AppRoutes.askPermissionScreen,
        page: () => AskPermissionScreenView(),
        binding: AskPermissionScreenViewBinding(),
        transition: Transition.rightToLeft),
    GetPage(
        name: AppRoutes.scheduleScreen,
        page: () => ScheduleScreenView(),
        binding: ScheduleScreenViewBinding(),
        transition: Transition.rightToLeft),
    GetPage(
        name: AppRoutes.resultScreen,
        page: () => ResultScreenView(),
        binding: ResultScreenViewBinding(),
        transition: Transition.rightToLeft),
    GetPage(
        name: AppRoutes.homeworkScreen,
        page: () => HomeworkView(),
        binding: HomeworkViewBinding(),
        transition: Transition.rightToLeft),
    ////////////////////////////////
    //Parent
    GetPage(
        name: AppRoutes.parentDashboard,
        page: () => ParentDashboardView(),
        binding: ParentDashboardViewBinding(),
        transition: Transition.fadeIn),

    //Notification
    GetPage(
        name: AppRoutes.notificationScreen,
        page: () => NotificationView(),
        binding: NotificationViewBinding(),
        transition: Transition.leftToRight)
  ];
}
