import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/'
    'parent_profile_tab/parent_profile_tab_controller.dart';

class ParentProfileTabView
    extends GetView<ParentProfileTabViewController> {
  const ParentProfileTabView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'profile'.tr,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Obx(
          () {
            if (controller
                .userController.isLoading.value) {
              return _buildLoadingSkeleton(
                context,
              );
            }

            final user =
                controller.userController.user;

            final profile =
                controller.userController.profile;

            if (user == null) {
              return Center(
                child: Text(
                  'profile_no_data'.tr,
                  style: Get.textTheme.bodyLarge,
                ),
              );
            }

            final isParent = _isParent(user);

            return RefreshIndicator(
              color:
                  Get.theme.colorScheme.primary,
              onRefresh:
                  controller.refreshProfile,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    _buildProfileHero(
                      user,
                      context,
                      isParent,
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      'personal_information'.tr,
                    ),

                    const SizedBox(height: 12),

                    isParent
                        ? _buildParentSection(
                            context,
                            user,
                            profile,
                          )
                        : _buildStudentSection(
                            context,
                            user,
                            profile,
                          ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      'general_section'.tr,
                    ),

                    const SizedBox(height: 12),

                    _buildGeneralSection(
                      context,
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      'account_section'.tr,
                    ),

                    const SizedBox(height: 12),

                    _buildCard(
                      children: [
                        _buildOptionItem(
                          icon: Icon(
                            PhosphorIconsRegular
                                .signOut,
                            color: Get
                                .theme
                                .colorScheme
                                .error,
                            size: 22,
                          ),
                          title:
                              'logout_action'.tr,
                          subtitle:
                              'sign_out_account'.tr,
                          onTap:
                              controller.logout,
                          titleColor: Get
                              .theme
                              .colorScheme
                              .error,
                          iconColor: Get
                              .theme
                              .colorScheme
                              .error,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // Parent section
  // =====================================================

  Widget _buildParentSection(
    BuildContext context,
    dynamic user,
    dynamic profile,
  ) {
    return _buildCard(
      children: [
        _buildOptionItem(
          icon: Icon(
            PhosphorIconsRegular.userCircle,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
          title: 'parent_information'.tr,
          subtitle:
              'view_your_information'.tr,
          onTap: () {
            _showParentAccountDialog(
              context,
              user,
              profile,
            );
          },
        ),

        _buildDivider(),

        _buildOptionItem(
          icon: Icon(
            PhosphorIconsRegular.student,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
          title:
              'children_information'.tr,
          subtitle:
              'view_linked_children'.tr,
          onTap: () {
            _showChildrenDialog(
              context,
            );
          },
        ),

        _buildDivider(),

        _buildOptionItem(
          icon: Icon(
            PhosphorIconsRegular.lockKey,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
          title:
              'forget_password_action'.tr,
          subtitle:
              'reset_your_password'.tr,
          onTap: () {
            Get.toNamed(
              AppRoutes.forgetPasswordScreen,
            );
          },
        ),
      ],
    );
  }

  // =====================================================
  // Student section
  // =====================================================

  Widget _buildStudentSection(
    BuildContext context,
    dynamic user,
    dynamic profile,
  ) {
    return _buildCard(
      children: [
        _buildOptionItem(
          icon: Icon(
            PhosphorIconsRegular.student,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
          title:
              'students_information'.tr,
          subtitle: 'your_information'.tr,
          onTap: () {
            _showStudentInformationDialog(
              context,
              user,
              profile,
            );
          },
        ),

        _buildDivider(),

        _buildOptionItem(
          icon: Icon(
            PhosphorIconsRegular.users,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
          title:
              'parents_information'.tr,
          subtitle:
              'your_parents_information'.tr,
          onTap: () {
            _showStudentParentDialog(
              context,
              profile,
            );
          },
        ),

        _buildDivider(),

        _buildOptionItem(
          icon: Icon(
            PhosphorIconsRegular.lockKey,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
          title:
              'forget_password_action'.tr,
          subtitle:
              'reset_your_password'.tr,
          onTap: () {
            Get.toNamed(
              AppRoutes.forgetPasswordScreen,
            );
          },
        ),
      ],
    );
  }

  // =====================================================
  // General section
  // =====================================================

  Widget _buildGeneralSection(
    BuildContext context,
  ) {
    return _buildCard(
      children: [
        _buildOptionItem(
          icon: Icon(
            PhosphorIconsRegular.sun,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
          title: 'change_theme'.tr,
          subtitle:
              'toggle_app_theme'.tr,
          onTap: () {
            controller.showThemeSheet(
              context,
            );
          },
        ),

        _buildDivider(),

        _buildOptionItem(
          icon: Icon(
            PhosphorIconsRegular.translate,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
          title: 'language'.tr,
          subtitle:
              'change_app_language'.tr,
          onTap: () {
            controller.showLanguageSheet(
              context,
            );
          },
        ),

        _buildDivider(),

        _buildOptionItem(
          icon: Icon(
            PhosphorIconsRegular.question,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
          title: 'faq'.tr,
          subtitle:
              'read_frequently_asked_questions'
                  .tr,
          onTap: () {
            controller.showFAQSheet(
              context,
            );
          },
        ),
      ],
    );
  }

  // =====================================================
  // Profile type
  // =====================================================

  bool _isParent(
    dynamic user,
  ) {
    return _read(
      () => user.role,
    ).toLowerCase() ==
        'parent';
  }

  String _read(
    dynamic Function() getter,
  ) {
    try {
      final value = getter();

      if (value == null) {
        return '';
      }

      return value.toString().trim();
    } catch (_) {
      return '';
    }
  }

  String _firstNotEmpty(
    List<String> values,
  ) {
    for (final value in values) {
      if (value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  // =====================================================
  // Profile hero
  // =====================================================

  Widget _buildProfileHero(
    dynamic user,
    BuildContext context,
    bool isParent,
  ) {
    final fullName = _read(
      () => user.fullName,
    ).isNotEmpty
        ? _read(
            () => user.fullName,
          )
        : '${_read(() => user.firstName)} '
                '${_read(() => user.lastName)}'
            .trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Theme.of(context)
                .colorScheme
                .primary,
            const Color(0xFF5DCAA5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(
                  alpha: 0.18,
                ),
            blurRadius: 24,
            offset:
                const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Obx(
                () => _buildAvatar(
                  user,
                  context,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty
                          ? '-'
                          : fullName,
                      style: Get
                          .textTheme.titleMedium
                          ?.copyWith(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _read(
                        () => user.email,
                      ),
                      style: Get
                          .textTheme.bodySmall
                          ?.copyWith(
                        color: Colors.white
                            .withValues(
                          alpha: 0.90,
                        ),
                      ),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.16,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          999,
                        ),
                      ),
                      child: Text(
                        isParent
                            ? 'parent'.tr
                            : 'student'.tr,
                        style: Get
                            .textTheme.bodySmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(
                alpha: 0.16,
              ),
              borderRadius:
                  BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  PhosphorIconsRegular.sparkle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'manage_account_confidence'
                        .tr,
                    textAlign:
                        TextAlign.center,
                    style: Get
                        .textTheme.bodySmall
                        ?.copyWith(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // Avatar
  // =====================================================

Widget _buildAvatar(
  dynamic user,
  BuildContext context,
) {
  final picked = controller.pickedImagePath.value;
  final avatarUrl = _read(() => user.avatarUrl);

  final bool hasImage =
      (picked != null && picked.isNotEmpty) ||
      avatarUrl.isNotEmpty;

  final ImageProvider<Object>? avatarProvider;

  if (picked != null && picked.isNotEmpty) {
    avatarProvider = FileImage(
      File(picked),
    );
  } else if (avatarUrl.isNotEmpty) {
    avatarProvider = NetworkImage(
      avatarUrl,
    );
  } else {
    avatarProvider = null;
  }

  return Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      GestureDetector(
        onTap: hasImage
            ? () {
                _showFullImageViewer(user);
              }
            : null,
        child: Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              startAngle: 2.356,
              colors: [
                Theme.of(context).colorScheme.primary,
                const Color(0xFF5DCAA5),
                Theme.of(context).colorScheme.primary,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      Theme.of(context).colorScheme.surface,
                  backgroundImage: avatarProvider,
                  child: !hasImage
                      ? _buildFallback(
                          user,
                          context,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 2,
        right: 2,
        child: GestureDetector(
          onTap: () {
            controller.showImagePickerSheet(
              context,
            );
          },
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2.5,
              ),
            ),
            child: const Icon(
              PhosphorIconsRegular.camera,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );
}
void _showFullImageViewer(
  dynamic user,
) {
  final picked =
      controller.pickedImagePath.value;

  final avatarUrl = _read(
    () => user.avatarUrl,
  );

  if ((picked == null || picked.isEmpty) &&
      avatarUrl.isEmpty) {
    return;
  }

  final ImageProvider<Object> imageProvider;

  if (picked != null && picked.isNotEmpty) {
    imageProvider = FileImage(
      File(picked),
    );
  } else {
    imageProvider = NetworkImage(
      avatarUrl,
    );
  }

  Get.dialog(
    GestureDetector(
      onTap: Get.back,
      child: Material(
        color: Colors.black.withValues(
          alpha: 0.85,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 54,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: Get.back,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Colors.black.withValues(
                      alpha: 0.35,
                    ),
                    foregroundColor:
                        Colors.white,
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
    barrierColor: Colors.black54,
  );
}
  Widget _buildFallback(
    dynamic user,
    BuildContext context,
  ) {
    final name = _read(
      () => user.fullName,
    ).isNotEmpty
        ? _read(
            () => user.fullName,
          )
        : '${_read(() => user.firstName)} '
                '${_read(() => user.lastName)}'
            .trim();

    if (name.isNotEmpty) {
      final parts =
          name.split(RegExp(r'\s+'));

      final initials =
          parts.length >= 2
              ? '${parts.first[0]}'
                  '${parts.last[0]}'
                  .toUpperCase()
              : name
                  .substring(
                    0,
                    name.length >= 2
                        ? 2
                        : name.length,
                  )
                  .toUpperCase();

      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFAFA9EC),
              Theme.of(context)
                  .colorScheme
                  .primary,
            ],
            begin: Alignment.topLeft,
            end:
                Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 34,
              fontWeight:
                  FontWeight.w500,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
      );
    }

    return const Icon(
      PhosphorIconsRegular.userCircle,
      size: 44,
      color: Color(0xFFAFA9EC),
    );
  }

  // =====================================================
  // Parent information dialog
  // =====================================================
void _showParentAccountDialog(
  BuildContext context,
  dynamic user,
  dynamic profile,
) {
  _showInformationDialog(
    context: context,
    icon: PhosphorIconsRegular.userCircle,
    title: 'parent_information'.tr,
    subtitle: 'personal_profile_details'.tr,
    rows: [
      MapEntry(
        'full_name'.tr,
        _read(
          () => user.fullName,
        ),
      ),
      MapEntry(
        'email'.tr,
        _read(
          () => user.email,
        ),
      ),
      MapEntry(
        'phone_number'.tr,
        _read(
          () => user.phone,
        ),
      ),
    ],
  );
}
  // =====================================================
  // Children dialog
  // =====================================================

  void _showChildrenDialog(
    BuildContext context,
  ) {
    controller.loadLinkedChildren();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(ctx)
                          .height *
                      0.72,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                16,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildDialogHeader(
                    icon:
                        PhosphorIconsRegular
                            .student,
                    title:
                        'children_information'
                            .tr,
                    subtitle:
                        'linked_student_accounts'
                            .tr,
                  ),

                  const SizedBox(height: 18),

                  Flexible(
                    child: Obx(
                      () {
                        if (controller
                            .isChildrenLoading
                            .value) {
                          return const Center(
                            child:
                                CircularProgressIndicator(),
                          );
                        }

                        if (controller
                            .childrenError
                            .value
                            .isNotEmpty) {
                          return _buildChildrenError();
                        }

                        final children =
                            controller
                                .linkedChildren;

                        if (children.isEmpty) {
                          return _buildChildrenEmpty();
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount:
                              children.length,
                          separatorBuilder:
                              (_, __) {
                            return const SizedBox(
                              height: 10,
                            );
                          },
                          itemBuilder:
                              (context, index) {
                            final child =
                                children[index];

                            return _buildChildCard(
                              child,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: Get
                            .theme
                            .colorScheme
                            .primary,
                        foregroundColor: Get
                            .theme
                            .colorScheme
                            .onPrimary,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      child: Text(
                        'close_button'.tr,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          color: Get.theme.colorScheme.onPrimary
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChildrenEmpty() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color:
            Get.theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.dividerColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Get
                  .theme.colorScheme.primary
                  .withValues(
                    alpha: 0.10,
                  ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.student,
              size: 38,
              color: Get
                  .theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'no_linked_children'.tr,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyLarge
                ?.copyWith(
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenError() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color:
            Get.theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Get
              .theme.colorScheme.error
              .withValues(
                alpha: 0.30,
              ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsRegular
                .warningCircle,
            size: 40,
            color:
                Get.theme.colorScheme.error,
          ),

          const SizedBox(height: 12),

          Text(
            'cannot_load_children'.tr,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyLarge
                ?.copyWith(
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed:
                controller.loadLinkedChildren,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: Text(
              'try_again'.tr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(
    Map<String, dynamic> child,
  ) {
    final name = _firstNotEmpty(
      [
        child['student_name']
                ?.toString() ??
            '',
        child['full_name']
                ?.toString() ??
            '',
        child['name']?.toString() ??
            '',
        '${child['first_name'] ?? ''} '
                '${child['last_name'] ?? ''}'
            .trim(),
      ],
    );

    final code = _firstNotEmpty(
      [
        child['student_code']
                ?.toString() ??
            '',
        child['code']?.toString() ??
            '',
      ],
    );

    final className = _firstNotEmpty(
      [
        child['class_name']
                ?.toString() ??
            '',
        child['school_class']
                ?.toString() ??
            '',
        child['class']?.toString() ??
            '',
      ],
    );

    final avatarUrl = _firstNotEmpty(
      [
        child['avatar_url']
                ?.toString() ??
            '',
        child['avatar']?.toString() ??
            '',
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            Get.theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Get
                .theme.colorScheme.primary
                .withValues(
                  alpha: 0.12,
                ),
            backgroundImage:
                avatarUrl.isNotEmpty
                    ? NetworkImage(
                        avatarUrl,
                      )
                    : null,
            child: avatarUrl.isEmpty
                ? Icon(
                    PhosphorIconsRegular
                        .student,
                    color: Get
                        .theme
                        .colorScheme
                        .primary,
                    size: 24,
                  )
                : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '-' : name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: Get
                      .textTheme.bodyLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                if (code.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${'student_code'.tr}: '
                    '$code',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Get
                        .textTheme.bodySmall
                        ?.copyWith(
                      color: Get
                          .theme
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(
                            alpha: 0.70,
                          ),
                    ),
                  ),
                ],

                if (className
                    .isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${'class_label'.tr}: '
                    '$className',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Get
                        .textTheme.bodySmall
                        ?.copyWith(
                      color: Get
                          .theme
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(
                            alpha: 0.70,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // Student information dialogs
  // =====================================================

  void _showStudentInformationDialog(
    BuildContext context,
    dynamic user,
    dynamic profile,
  ) {
    _showInformationDialog(
      context: context,
      icon:
          PhosphorIconsRegular.student,
      title:
          'students_information'.tr,
      subtitle:
          'academic_profile_details'.tr,
      rows: [
        MapEntry(
          'full_name'.tr,
          _read(
            () => user.fullName,
          ),
        ),
        MapEntry(
          'email'.tr,
          _read(
            () => user.email,
          ),
        ),
        MapEntry(
          'student_code'.tr,
          _read(
            () => profile.studentCode,
          ),
        ),
        MapEntry(
          'class_label'.tr,
          _read(
            () => profile.className,
          ),
        ),
        MapEntry(
          'gender'.tr,
          _read(
            () => profile.gender,
          ),
        ),
        MapEntry(
          'guardian_phone'.tr,
          _read(
            () => profile.guardianPhone,
          ),
        ),
      ],
    );
  }

  void _showStudentParentDialog(
    BuildContext context,
    dynamic profile,
  ) {
    _showInformationDialog(
      context: context,
      icon:
          PhosphorIconsRegular.users,
      title:
          'parents_information'.tr,
      subtitle:
          'guardian_contact_details'.tr,
      rows: [
        MapEntry(
          'guardian_name'.tr,
          _read(
            () => profile.guardianName,
          ),
        ),
        MapEntry(
          'guardian_phone'.tr,
          _read(
            () => profile.guardianPhone,
          ),
        ),
        MapEntry(
          'address'.tr,
          _read(
            () => profile.address,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // Generic information dialog
  // =====================================================

  void _showInformationDialog({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<
            MapEntry<String, String>>
        rows,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              16,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildDialogHeader(
                  icon: icon,
                  title: title,
                  subtitle: subtitle,
                ),

                const SizedBox(height: 18),

                Container(
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration: BoxDecoration(
                    color: Get
                        .theme
                        .colorScheme
                        .surface,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    border: Border.all(
                      color:
                          Get.theme.dividerColor,
                    ),
                  ),
                  child: Column(
                    children: List.generate(
                      rows.length,
                      (index) {
                        return Column(
                          children: [
                            _buildInfoRow(
                              rows[index].key,
                              rows[index].value,
                            ),
                            if (index <
                                rows.length - 1)
                              const SizedBox(
                                height: 10,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment:
                      Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: Get
                          .theme
                          .colorScheme
                          .primary,
                      foregroundColor: Get
                          .theme
                          .colorScheme
                          .onPrimary,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'close_button'.tr,
                      style: Get.textTheme.bodyLarge!.copyWith(
                        color: Get.theme.colorScheme.onPrimary
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Get
                .theme.colorScheme.primary
                .withValues(
                  alpha: 0.12,
                ),
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color:
                Get.theme.colorScheme.primary,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get
                    .textTheme.titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    final theme = Get.theme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: Get
                .textTheme.bodyMedium
                ?.copyWith(
              fontWeight:
                  FontWeight.w600,
              color: theme
                  .textTheme.bodySmall?.color
                  ?.withValues(
                    alpha: 0.70,
                  ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 4,
          child: Text(
            value.isNotEmpty
                ? value
                : '-',
            style:
                Get.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // Shared UI
  // =====================================================

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style:
          Get.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color:
            Get.theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildCard({
    required List<Widget> children,
  }) {
    final theme = Get.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildOptionItem({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    final theme = Get.theme;

    final effectiveTitleColor =
        titleColor ??
            theme
                .textTheme.bodyMedium?.color ??
            theme.colorScheme.onSurface;

    final effectiveIconColor =
        iconColor ??
            theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: effectiveIconColor
                      .withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: icon,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Get
                          .textTheme.bodyMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                        color:
                            effectiveTitleColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: Get
                          .textTheme.bodySmall
                          ?.copyWith(
                        color: theme
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(
                              alpha: 0.70,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                PhosphorIconsRegular
                    .caretRight,
                size: 18,
                color: theme
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(
                      alpha: 0.70,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 18,
      endIndent: 18,
      color: Get.theme.dividerColor,
    );
  }

  // =====================================================
  // Loading skeleton
  // =====================================================

  Widget _buildLoadingSkeleton(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme
          .colorScheme
          .surfaceContainerHighest,
      highlightColor:
          theme.colorScheme.surface,
      period:
          const Duration(milliseconds: 1300),
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Container(
              height: 210,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const _SkeletonBlock(
              width: 140,
              height: 16,
            ),

            const SizedBox(height: 12),

            _buildSkeletonCard(
              itemCount: 3,
            ),

            const SizedBox(height: 24),

            const _SkeletonBlock(
              width: 140,
              height: 16,
            ),

            const SizedBox(height: 12),

            _buildSkeletonCard(
              itemCount: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard({
    required int itemCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Get.theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          itemCount,
          (index) {
            return Column(
              children: [
                const Row(
                  children: [
                    _SkeletonBlock(
                      width: 44,
                      height: 44,
                      radius: 14,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          _SkeletonBlock(
                            width: 128,
                            height: 14,
                          ),
                          SizedBox(height: 8),
                          _SkeletonBlock(
                            width: 184,
                            height: 11,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (index <
                    itemCount - 1) ...[
                  const SizedBox(height: 14),
                  Divider(
                    color:
                        Get.theme.dividerColor,
                    height: 1,
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SkeletonBlock
    extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(radius),
      ),
    );
  }
}