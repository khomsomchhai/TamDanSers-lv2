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
    return SplashScreenBody(controller: controller);
  }
}

class SplashScreenBody extends StatefulWidget {
  final SplashScreenViewController controller;

  const SplashScreenBody({super.key, required this.controller});

  @override
  State<SplashScreenBody> createState() => _SplashScreenBodyState();
}

class _SplashScreenBodyState extends State<SplashScreenBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ).drive(Tween<double>(begin: 0.0, end: 1.0));

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ).drive(Tween<double>(begin: 0.7, end: 1.0));

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ).drive(Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: _slideAnimation.value * size.height * 0.03,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Hero(
                          tag: 'app_logo',
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white.withValues(alpha: 0.12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.dark.withValues(alpha: 0.12),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: SvgPicture.asset(
                                AppIcons.appIconWhite,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 28),
                  // Opacity(
                  //   opacity: _fadeAnimation.value,
                  //   child: const Text(
                  //     'TamDanSers',
                  //     style: TextStyle(
                  //       color: AppColors.white,
                  //       fontSize: 24,
                  //       fontWeight: FontWeight.w700,
                  //       letterSpacing: 1.2,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 10),
                  // Opacity(
                  //   opacity: _fadeAnimation.value,
                  //   child: const Text(
                  //     'Welcome to your learning journey',
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       color: Colors.white70,
                  //       fontSize: 14,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}