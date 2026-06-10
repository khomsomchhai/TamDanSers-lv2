import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/localization/localization_service.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';

part 'login_screen_binding.dart';
part 'login_screen_controller.dart';

class LoginScreenView extends GetView<LoginScreenViewController> {
  const LoginScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.updateKeyboard(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() => SingleChildScrollView(
                physics: controller.isKeyboardOpen.value
                ? BouncingScrollPhysics()
                : NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              _buildHeader(),
                              SizedBox(height: 50,),
                              _buildForm(),
                              SizedBox(height: 10,),
                            ],
                          ),
                          Column(
                            children: [
                              _buildFooter(),
                              SizedBox(height: 20,),
                            ],
                          ),
                        ],
                      ),
                ),
              )),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupMenuButton<String>(
              onSelected: (lang) {
                LocalizationService().changeLocale(lang);
              },
              position: PopupMenuPosition.under,
              borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'en',
                    child: Row(
                      children: [
                        Image.asset(
                          AppIcons.englishIcon,
                          width: 24,
                        ),
                        SizedBox(width: 10,),
                        Text(
                          "English",
                          style: Get.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'km',
                    child: Row(
                      children: [
                        Image.asset(
                          AppIcons.khmerIcon,
                          width: 24,
                        ),
                        SizedBox(width: 10,),
                        Text(
                          "ភាសាខ្មែរ",
                          style: GoogleFonts.googleSans(),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    Get.locale?.languageCode == 'km'
                        ? AppIcons.khmerIcon
                        : AppIcons.englishIcon,
                    width: 24,
                  ),
                  SizedBox(width: 10,),
                  Text(
                    Get.locale?.languageCode == 'km' ? "ភាសាខ្មែរ" : "English",
                    style: Get.locale?.languageCode == 'km' ? GoogleFonts.googleSans() : GoogleFonts.spaceGrotesk(),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20,),
        SizedBox(
          height: 140,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(AppNumbers.radiusMedium),
            child: SvgPicture.asset(
              AppIcons.appIconPrimary,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          Text(
            "Login",
            style: Get.textTheme.titleLarge,
          ),
          SizedBox(height: 20,),
          CustomTextField(
            hintText: "Enter your ID",
            controller: controller.idCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Required";
              }
              return null;
            },
            prefixIcon: Icon(Icons.person_outline),
          ),
          SizedBox(
            height: 16,
          ),
          Obx(() => CustomTextField(
                hintText: "Enter your password",
                controller: controller.pwdCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
                prefixIcon: Icon(Icons.lock_outline),
                isPwd: true,
                isHide: controller.isHidePwd.value,
                suffixIcon: Bounceable(
                  onTap: () {
                    controller.togglePwd();
                  },
                  child: Icon(
                    controller.isHidePwd.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.dark,
                  ),
                ),
              )),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Bounceable(
                onTap: () {},
                child: Text(
                  "Forget Password?",
                  style:
                      Get.textTheme.bodyLarge!.copyWith(color: AppColors.info),
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Obx(() => SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomButton(
                  text: "Login",
                  onPressed: () {
                    controller.login();
                  },
                  isLoading: controller.isLoading.value,
                  variant: ButtonVariant.primary,
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: Get.textTheme.bodyLarge,
            ),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {},
              child: Text("Register",
                  style: Get.textTheme.bodyLarge!
                      .copyWith(color: AppColors.info)),
            ),
          ],
        ),
      ],
    );
  }
}
