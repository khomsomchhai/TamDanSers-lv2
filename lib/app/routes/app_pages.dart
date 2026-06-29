import 'package:get/route_manager.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/screens/auth/login_screen/login_screen_view.dart';
import 'package:tamdansers_lv2/screens/auth/splash_screen/splash_screen_view.dart';
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
        transition: Transition.leftToRight),
    GetPage(
        name: AppRoutes.scheduleScreen,
        page: () => ScheduleScreenView(),
        binding: ScheduleScreenViewBinding(),
        transition: Transition.leftToRight),
    GetPage(
        name: AppRoutes.resultScreen,
        page: () => ResultScreenView(),
        binding: ResultScreenViewBinding(),
        transition: Transition.leftToRight),
    GetPage(
        name: AppRoutes.homeworkScreen,
        page: () => HomeworkView(),
        binding: HomeworkViewBinding(),
        transition: Transition.leftToRight),
    GetPage(
      name: AppRoutes.askPermissionScreen, 
      page: () => AskPermissionScreenView(),
      binding: AskPermissionScreenViewBinding(),
      transition: Transition.rightToLeft
    ),
    GetPage(
      name: AppRoutes.scheduleScreen, 
      page: () => ScheduleScreenView(),
      binding: ScheduleScreenViewBinding(),
      transition: Transition.rightToLeft
    ),
    GetPage(
      name: AppRoutes.resultScreen, 
      page: () => ResultScreenView(),
      binding: ResultScreenViewBinding(),
      transition: Transition.rightToLeft
    ),

    ////////////////////////////////
    //Parent
    GetPage(
        name: AppRoutes.parentDashboard,
        page: () => ParentDashboardView(),
        binding: ParentDashboardViewBinding(),
        transition: Transition.fadeIn),
  ];
}
