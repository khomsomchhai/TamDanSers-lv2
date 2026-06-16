import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_placeholder.dart';

part 'home_tab_binding.dart';
part 'home_tab_controller.dart';

class HomeTabView extends GetView<HomeTabViewController> {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Obx(() => controller.userController.isLoading.value
                ? CustomHeaderPlaceholder()
                : CustomHeader(controller: controller.userController),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}