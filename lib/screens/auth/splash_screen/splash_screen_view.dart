import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';

part 'splash_screen_binding.dart';
part 'splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenViewController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = (size.width * 0.4).clamp(120.0, 160.0);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: controller.animationController,
          builder: (context, child) {
            return Opacity(
              opacity: controller.logoFade.value,
              child: Transform.scale(
                scale: controller.logoScale.value,
                child: Hero(
                  tag: 'app_logo',
                  child: SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: SvgPicture.asset(
                      AppIcons.appIconWhite,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}