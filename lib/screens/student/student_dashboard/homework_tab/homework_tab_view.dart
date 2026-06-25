import 'package:flutter/material.dart';
import 'package:get/get.dart';
<<<<<<< HEAD
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
=======
import 'package:tamdansers_lv2/screens/student/homework/homework_view.dart';
>>>>>>> e0f2ef0 (fix)

part 'homework_tab_binding.dart';
part 'homework_tab_controller.dart';

class HomeworkTabView extends GetView<HomeworkTabViewController> {
  const HomeworkTabView({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      appBar: CustomAppBar(
        title: "homework".tr,
        showBackButton: false,
        unreadCount: 2,
      ),
    );
=======
    return const HomeworkView();
>>>>>>> e0f2ef0 (fix)
  }
}