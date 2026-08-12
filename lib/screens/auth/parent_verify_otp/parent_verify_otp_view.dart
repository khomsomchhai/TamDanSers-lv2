import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/utils/dio_exception_handler.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';

part 'parent_verify_otp_binding.dart';
part 'parent_verify_otp_controller.dart';

const int _kOtpLength = 6;
const double _kBoxSize = 48;
const double _kBoxGap = 10;

class ParentVerifyOtpView extends GetView<ParentVerifyOtpViewController> {
  const ParentVerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(title: '', showNotification: false),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildOtpRow(context, theme),
              const SizedBox(height: 16),
              _buildResendRow(theme),
              const SizedBox(height: 28),
              _buildSubmitButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.24),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            PhosphorIconsRegular.shieldCheck,
            color: theme.colorScheme.onPrimary,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'verification_code_otp'.tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'otp_instructions'.tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpRow(BuildContext context, ThemeData theme) {
    return Form(
      key: controller.formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _kOtpLength; i++) ...[
            if (i != 0) const SizedBox(width: _kBoxGap),
            _OtpDigitBox(
              index: i,
              controller: controller.otpControllers[i],
              focusNode: controller.otpFocusNodes[i],
              theme: theme,
              onChanged: (value) => _handleChanged(context, i, value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResendRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'did_not_receive_otp'.tr,
          style: Get.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: controller.resendOtp,
          child: Text(
            'resend_otp'.tr,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.info,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.info,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      height: 52,
      child: Obx(
        () => CustomButton(
          text: 'continue_label'.tr,
          onPressed: controller.verifyOtp,
          variant: ButtonVariant.primary,
          isLoading: controller.isLoading.value,
        ),
      ),
    );
  }

  void _handleChanged(BuildContext context, int index, String value) {
    if (value.length > 1) {
      _distributePastedCode(value, index);
      return;
    }
    controller.handleOtpChanged(context, index, value);
    if (value.isNotEmpty && index < _kOtpLength - 1) {
      FocusScope.of(context).requestFocus(controller.otpFocusNodes[index + 1]);
    } else if (value.isNotEmpty && index == _kOtpLength - 1) {
      FocusScope.of(context).unfocus();
    }
  }

  void _distributePastedCode(String pasted, int startIndex) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    var boxIndex = 0;
    for (var i = 0; i < digits.length && boxIndex < _kOtpLength; i++, boxIndex++) {
      controller.otpControllers[boxIndex].text = digits[i];
    }

    final nextEmpty = boxIndex < _kOtpLength ? boxIndex : _kOtpLength - 1;
    controller.otpFocusNodes[nextEmpty].requestFocus();

    if (boxIndex >= _kOtpLength) {
      controller.otpFocusNodes[_kOtpLength - 1].unfocus();
    }
  }
}

class _OtpDigitBox extends StatefulWidget {
  const _OtpDigitBox({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.theme,
    required this.onChanged,
  });

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ThemeData theme;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpDigitBox> createState() => _OtpDigitBoxState();
}

class _OtpDigitBoxState extends State<_OtpDigitBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isFilled = widget.controller.text.isNotEmpty;
    final borderColor = _isFocused
        ? theme.colorScheme.primary
        : isFilled
            ? theme.colorScheme.primary.withOpacity(0.55)
            : theme.dividerColor.withOpacity(0.6);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: _kBoxSize,
      height: _kBoxSize + 8,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 1.6 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: KeyboardListener(
          focusNode: FocusNode(skipTraversal: true),
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                widget.controller.text.isEmpty &&
                widget.index > 0) {
              Focus.of(context).previousFocus();
            }
          },
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: widget.index == 0,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            cursorColor: theme.colorScheme.primary,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              setState(() {});
              widget.onChanged(value);
            },
          ),
        ),
      ),
    );
  }
}