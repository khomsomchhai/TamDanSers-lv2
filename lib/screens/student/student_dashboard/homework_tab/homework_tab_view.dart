import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';

part 'homework_tab_binding.dart';
part 'homework_tab_controller.dart';

class HomeworkTabView extends GetView<HomeworkTabViewController> {
  const HomeworkTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "homework".tr,
        showBackButton: false,
        unreadCount: 2,
      ),
    );
  }
}