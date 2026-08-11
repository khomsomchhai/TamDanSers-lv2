import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/homework_services.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';
import 'package:tamdansers_lv2/data/model/homework_model.dart';
import 'package:tamdansers_lv2/data/model/submission_model.dart';
import 'package:tamdansers_lv2/screens/student/homework/homework_detail_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/student_dashboard_view.dart';

part 'homework_binding.dart';
part 'homework_controller.dart';

class HomeworkView extends GetView<HomeworkViewController> {
  const HomeworkView({super.key});

  @override
  Widget build(BuildContext context) {
    // If the controller isn't registered (e.g. if loaded directly outside dashboard binding), register it.
    final controller = Get.isRegistered<HomeworkViewController>()
        ? Get.find<HomeworkViewController>()
        : Get.put(HomeworkViewController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'homework'.tr,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 2. Custom Segmented Tab Bar Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 54,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xffEBEBF1)
                      : Colors.black26,
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Obx(
                  () => Row(
                    children: [
                      // Ongoing Tab Item
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.changeTab(0),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: controller.selectedTabIndex.value == 0
                                  ? (Theme.of(context).brightness ==
                                          Brightness.light
                                      ? AppColors.white
                                      : Colors.grey[850])
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: controller.selectedTabIndex.value == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              Get.locale?.languageCode == 'km'
                                  ? 'រង់ចាំពិនិត្យ'
                                  : 'Pending',
                              style: Get.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: controller.selectedTabIndex.value == 0
                                    ? AppColors.primary
                                    : AppColors.hintColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Completed Tab Item
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.changeTab(1),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: controller.selectedTabIndex.value == 1
                                  ? (Theme.of(context).brightness ==
                                          Brightness.light
                                      ? AppColors.white
                                      : Colors.grey[850])
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: controller.selectedTabIndex.value == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              Get.locale?.languageCode == 'km'
                                  ? 'ពិនិត្យ'
                                  : 'Check',
                              style: Get.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: controller.selectedTabIndex.value == 1
                                    ? AppColors.primary
                                    : AppColors.hintColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 3. Main Content: Subject List (1 by 1) or Selected Subject Homeworks List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final isSubjectOpen = controller.selectedSubject.value != null;

                if (isSubjectOpen) {
                  return _buildSingleSubjectView(context, controller);
                } else {
                  return _buildSubjectListView(context, controller);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. SUBJECT LIST VIEW (Shows Subject Cards 1 by 1)
  // ===========================================================================
  String _formatDisplayDate(String rawDate, bool isKm) {
    if (rawDate.trim().isEmpty) return isKm ? 'មិនកំណត់' : 'No deadline';
    var trimmed = rawDate.trim();

    if (trimmed.toLowerCase().startsWith('until ')) {
      trimmed = trimmed.substring(6).trim();
    } else if (trimmed.startsWith('រហូតដល់ ')) {
      trimmed = trimmed.substring(8).trim();
    } else if (trimmed.toLowerCase() == 'until' || trimmed == 'រហូតដល់') {
      return '';
    }

    try {
      DateTime? dt;
      if (trimmed.contains('T')) {
        dt = DateTime.tryParse(trimmed);
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(trimmed)) {
        dt = DateTime.tryParse(trimmed.substring(0, 10));
      }

      if (dt != null) {
        final monthsKm = [
          'មករា',
          'កុម្ភៈ',
          'មីនា',
          'មេសា',
          'ឧសភា',
          'មិថុនា',
          'កក្កដា',
          'សីហា',
          'កញ្ញា',
          'តុលា',
          'វិច្ឆិកា',
          'ធ្នូ'
        ];
        final monthsEn = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        final monthStr = isKm ? monthsKm[dt.month - 1] : monthsEn[dt.month - 1];
        final dayStr = dt.day.toString().padLeft(2, '0');

        String timePart = '';
        if (trimmed.contains(' ')) {
          final parts = trimmed.split(' ');
          if (parts.length > 1 && parts[1].contains(':')) {
            final tParts = parts[1].split(':');
            final hour = int.tryParse(tParts[0]) ?? 0;
            final minute = tParts[1];
            final ampm = hour >= 12 ? 'PM' : 'AM';
            final hour12 = hour % 12 == 0 ? 12 : hour % 12;
            timePart = ' ${hour12.toString().padLeft(2, '0')}:$minute $ampm';
          }
        }

        return '$dayStr $monthStr ${dt.year}$timePart';
      }
    } catch (_) {}

    return trimmed;
  }

  Widget _buildSubjectListView(
    BuildContext context,
    HomeworkViewController controller,
  ) {
    final groups = controller.selectedTabIndex.value == 0
        ? controller.ongoingSubjectGroups
        : controller.completedSubjectGroups;

    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 54,
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              Get.locale?.languageCode == 'km'
                  ? 'គ្មានកិច្ចការផ្ទះទេ'
                  : 'No homework available',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: controller.fetchHomework,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildSubjectGroupCard(context, controller, group);
        },
      ),
    );
  }

  Widget _buildSubjectGroupCard(
    BuildContext context,
    HomeworkViewController controller,
    SubjectHomeworkGroup group,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isKm = Get.locale?.languageCode == 'km';

    final subjectColor = group.iconColor;
    final subjectBgColor = group.iconBgColor;
    final subjectIcon = group.icon;

    final itemCount = group.items.length;
    final countLabel = isKm
        ? '$itemCount កិច្ចការ'
        : '$itemCount Task${itemCount > 1 ? 's' : ''}';

    return Bounceable(
      onTap: () {
        controller.openSubject(group.subjectName);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDarkMode
                ? subjectColor.withValues(alpha: 0.25)
                : subjectColor.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: subjectColor.withValues(alpha: isDarkMode ? 0.08 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Vertical Color Bar Indicator with Gradient
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        subjectColor,
                        subjectColor.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Card Inner Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Subject Icon + Title & Full Teacher Name + Arrow
                        Row(
                          children: [
                            // Subject Icon Box
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? subjectColor.withValues(alpha: 0.18)
                                    : subjectBgColor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: subjectColor.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                subjectIcon,
                                color: subjectColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Title and Teacher full name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.subjectName,
                                    style: Get.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: isDarkMode
                                          ? AppColors.white
                                          : AppColors.dark,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline_rounded,
                                        size: 14,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : AppColors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          group.teacherName.isNotEmpty
                                              ? group.teacherName
                                              : (isKm
                                                  ? 'មិនស្គាល់'
                                                  : 'Unknown Teacher'),
                                          style:
                                              Get.textTheme.bodySmall?.copyWith(
                                            color: isDarkMode
                                                ? Colors.grey[400]
                                                : AppColors.grey,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Arrow Button Indicator
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[800]
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: subjectColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: isDarkMode
                              ? Colors.grey[800]
                              : const Color(0xFFEFF2F6),
                        ),
                        const SizedBox(height: 10),

                        // Row 2: Status Badges (Left) & Task Count (Right)
                        Builder(builder: (context) {
                          final pendingCount = group.items
                              .where((i) => i.status == HomeworkStatus.none)
                              .length;
                          final submittedCount = group.items
                              .where(
                                  (i) => i.status == HomeworkStatus.submitted)
                              .length;
                          final checkedCount = group.items
                              .where((i) => i.status == HomeworkStatus.checked)
                              .length;

                          final List<Widget> statusBadges = [];

                          if (controller.selectedTabIndex.value == 0) {
                            if (submittedCount > 0) {
                              statusBadges.add(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffDBEAFE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isKm
                                        ? '$submittedCount បានប្រគល់'
                                        : '$submittedCount Submitted',
                                    style: Get.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xff2563EB),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (pendingCount > 0) {
                              statusBadges.add(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFEF3C7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isKm
                                        ? '$pendingCount រង់ចាំ'
                                        : '$pendingCount Pending',
                                    style: Get.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xffD97706),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            }
                          } else {
                            statusBadges.add(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.success.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isKm
                                      ? '$checkedCount ពិនិត្យ'
                                      : '$checkedCount Checked',
                                  style: Get.textTheme.bodySmall?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: statusBadges
                                    .expand(
                                        (w) => [w, const SizedBox(width: 5)])
                                    .toList()
                                  ..removeLast(),
                              ),
                              Text(
                                countLabel,
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : AppColors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. SINGLE SUBJECT HOMEWORK ASSIGNMENTS VIEW (When Subject is Clicked)
  // ===========================================================================
  Widget _buildSingleSubjectView(
    BuildContext context,
    HomeworkViewController controller,
  ) {
    final isKm = Get.locale?.languageCode == 'km';
    final subjectName = controller.selectedSubject.value ?? '';
    final items = controller.selectedSubjectHomeworks;
    final subjectColor = SubjectUi.color(subjectName);

    return Column(
      children: [
        // Subject Hero Header Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                subjectColor,
                subjectColor.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: subjectColor.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Bounceable(
                onTap: controller.backToSubjectList,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  SubjectUi.icon(subjectName),
                  size: 24,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isKm
                          ? 'កិច្ចការផ្ទះ $subjectName'
                          : '$subjectName Homework',
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isKm
                          ? '${items.length} កិច្ចការសរុប'
                          : '${items.length} Assignment${items.length > 1 ? 's' : ''} Total',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Homework Items List for this Subject
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    isKm
                        ? 'គ្មានកិច្ចការផ្ទះក្នុងមុខវិជ្ជានេះទេ'
                        : 'No homework in $subjectName',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildHomeworkAssignmentCard(
                        context, controller, item, subjectColor);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHomeworkAssignmentCard(
    BuildContext context,
    HomeworkViewController controller,
    HomeworkItem item,
    Color subjectColor,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isKm = Get.locale?.languageCode == 'km';

    String badgeText = '';
    Color badgeTextColor = Colors.black;
    Color badgeBgColor = Colors.grey;

    if (item.status == HomeworkStatus.none) {
      badgeText = isKm ? 'រង់ចាំពិនិត្យ' : 'Pending';
      badgeTextColor = const Color(0xffD97706);
      badgeBgColor = const Color(0xffFEF3C7);
    } else if (item.status == HomeworkStatus.submitted) {
      badgeText = isKm ? 'បានប្រគល់' : 'Submitted';
      badgeTextColor = const Color(0xff2563EB);
      badgeBgColor = const Color(0xffDBEAFE);
    } else if (item.status == HomeworkStatus.checked) {
      badgeText = isKm ? 'ពិនិត្យ' : 'Check';
      badgeTextColor = AppColors.success;
      badgeBgColor = AppColors.success.withValues(alpha: 0.12);
    }

    final isCompleted = item.status == HomeworkStatus.submitted ||
        item.status == HomeworkStatus.checked;

    final formattedDate = _formatDisplayDate(item.date, isKm);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[800]!
              : AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4.5,
                color: subjectColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title.isNotEmpty
                                  ? item.title
                                  : item.subjectName,
                              style: Get.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDarkMode
                                    ? AppColors.white
                                    : AppColors.dark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badgeText,
                              style: Get.textTheme.bodySmall?.copyWith(
                                color: badgeTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(builder: (context) {
                            final datePrefix = isCompleted
                                ? (isKm ? 'បានប្រគល់' : 'Submitted')
                                : (isKm ? 'រហូតដល់' : 'Until');
                            final displayDateText =
                                formattedDate.startsWith(datePrefix)
                                    ? formattedDate
                                    : '$datePrefix $formattedDate';

                            return Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    isCompleted
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.schedule_rounded,
                                    color: AppColors.grey,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      displayDateText,
                                      style: Get.textTheme.bodySmall?.copyWith(
                                        color: AppColors.grey,
                                        fontSize: 12.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          Bounceable(
                            onTap: () {
                              controller.showHomeworkDetails(context, item);
                            },
                            child: Text(
                              isKm ? 'មើលលម្អិត' : 'View details',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
