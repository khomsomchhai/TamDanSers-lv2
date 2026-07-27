import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/screens/student/homework/homework_view.dart';

part 'homework_tab_binding.dart';
part 'homework_tab_controller.dart';

class HomeworkTabView extends GetView<HomeworkTabViewController> {
  const HomeworkTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeworkView();
  }
}