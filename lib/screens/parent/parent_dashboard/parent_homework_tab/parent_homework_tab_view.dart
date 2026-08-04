import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/homework_services.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';
import 'package:tamdansers_lv2/data/model/homework_model.dart';

part 'parent_homework_tab_binding.dart';
part 'parent_homework_tab_controller.dart';

class ParentHomeworkTabView extends GetView<ParentHomeworkTabViewController> {
  const ParentHomeworkTabView({super.key});

  String _getLocalizedSubjectName(String subjectName) {
    final isKm = Get.locale?.languageCode == 'km';
    if (!isKm) return subjectName;

    final s = subjectName.toLowerCase();
    if (s.contains('khmer') || s.contains('ភាសាខ្មែរ')) return 'ភាសាខ្មែរ';
    if (s.contains('math') || s.contains('គណិត')) return 'គណិតវិទ្យា';
    if (s.contains('bio') || s.contains('ជីវ')) return 'ជីវវិទ្យា';
    if (s.contains('physic') || s.contains('រូប')) return 'រូបវិទ្យា';
    if (s.contains('chem') || s.contains('គីមី')) return 'គីមីវិទ្យា';
    if (s.contains('eng') || s.contains('អង់គ្លេស')) return 'ភាសាអង់គ្លេស';
    if (s.contains('hist') || s.contains('ប្រវត្តិ')) return 'ប្រវត្តិវិទ្យា';
    if (s.contains('geog') || s.contains('ភូមិ')) return 'ភូមិវិទ្យា';
    if (s.contains('earth') || s.contains('ផែនដី')) return 'ផែនដីវិទ្យា';
    if (s.contains('civic') || s.contains('ពលរដ្ឋ')) return 'ពលរដ្ឋវិទ្យា';
    if (s.contains('ict') ||
        s.contains('computer') ||
        s.contains('ព័ត៌មានវិទ្យា')) {
      return 'ព័ត៌មានវិទ្យា';
    }
    return subjectName;
  }

  String _getLocalizedScore(String score) {
    final isKm = Get.locale?.languageCode == 'km';
    if (!isKm) return score;
    if (score.toLowerCase() == 'pending') return 'រង់ចាំកែ';
    if (score.toLowerCase() == 'completed') return 'បានបញ្ចប់';
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ParentHomeworkTabViewController>()
        ? Get.find<ParentHomeworkTabViewController>()
        : Get.put(ParentHomeworkTabViewController());

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchHomework,
          child: Obx(() {
            final isSubjectOpen = controller.selectedSubject.value != null;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Top Header Sliver
                SliverToBoxAdapter(
                  child: isSubjectOpen
                      ? _buildSubjectDetailHeader(context, controller)
                      : _buildMainOverviewHeader(context, controller),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // Main Content Sliver (Subject Cards Overview vs 1 Subject Homework List)
                if (controller.isLoading.value)
                  const SliverFillRemaining(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (isSubjectOpen)
                  _buildSingleSubjectHomeworkSliver(context, controller)
                else
                  _buildSubjectGridSliver(context, controller),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. OVERVIEW SCREEN: Main Top Header + Hero Summary Card
  // ===========================================================================
  Widget _buildMainOverviewHeader(
    BuildContext context,
    ParentHomeworkTabViewController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Child Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'homework'.tr,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Student Selector Pill
              Obx(() {
                if (controller.students.length <= 1) {
                  return const SizedBox.shrink();
                }

                return Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      value: controller.selectedChild.value,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      dropdownColor:
                          isDarkMode ? Colors.grey[850] : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      items: controller.students.map((student) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: student,
                          child: Text(
                            student['student_name']?.toString() ?? '',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode ? AppColors.white : AppColors.dark,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (child) {
                        if (child != null) {
                          controller.selectChild(child);
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 16),

          // Hero Summary Card
          _buildHeroSummaryCard(context, controller),

          const SizedBox(height: 22),

          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Get.locale?.languageCode == 'km'
                    ? 'មុខវិជ្ជាទាំងអស់'
                    : 'All Subjects',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.dark,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.subjectGroupList.length} Subjects',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSummaryCard(
    BuildContext context,
    ParentHomeworkTabViewController controller,
  ) {
    final isKm = Get.locale?.languageCode == 'km';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E4CB9),
            Color(0xFF4A6AEB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B59C9).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Left Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isKm
                            ? 'សរុបដំណើការកិច្ចការផ្ទះ'
                            : 'Overall Homework Progress',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isKm
                          ? 'សម្រេចបាន ${(controller.overallCompletionRate * 100).toInt()}%'
                          : '${(controller.overallCompletionRate * 100).toInt()}% Completed',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // Circular Progress Ring
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: controller.overallCompletionRate,
                      strokeWidth: 6.5,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      color: Colors.white,
                    ),
                    Center(
                      child: Text(
                        '${(controller.overallCompletionRate * 100).toInt()}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 14),

          // Status Counters Row: Done, Not Complete, Missing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStatPill(
                label: isKm ? 'បានបញ្ចប់' : 'Done',
                count: controller.totalDoneCount,
                color: const Color(0xFF4ADE80),
              ),
              _buildSummaryStatPill(
                label: isKm ? 'មិនទាន់រួច' : 'Not Complete',
                count: controller.totalNotCompleteCount,
                color: const Color(0xFF60A5FA),
              ),
              _buildSummaryStatPill(
                label: isKm ? 'ហួសកំណត់' : 'Missing',
                count: controller.totalMissingCount,
                color: const Color(0xFFF87171),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatPill({
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12,
          ),
        ),
        Text(
          '$count',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. SUBJECT CARDS GRID (SliverGrid for 2 Columns)
  // ===========================================================================
  Widget _buildSubjectGridSliver(
    BuildContext context,
    ParentHomeworkTabViewController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final subjects = controller.subjectGroupList;

    if (subjects.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(context));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.92,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final group = subjects[index];
            return _buildSubjectCard(context, controller, group, isDarkMode);
          },
          childCount: subjects.length,
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    ParentHomeworkTabViewController controller,
    SubjectGroupItem group,
    bool isDarkMode,
  ) {
    final isKm = Get.locale?.languageCode == 'km';
    return Bounceable(
      onTap: () => controller.openSubject(group.name),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDarkMode
                ? Colors.grey[800]!
                : AppColors.border.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon & Status Badge Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: group.bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    group.icon,
                    color: group.color,
                    size: 23,
                  ),
                ),
                if (group.missingCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isKm
                          ? '${group.missingCount} ហួសកំណត់'
                          : '${group.missingCount} Missing',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  )
                else if (group.notCompleteCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isKm
                          ? '${group.notCompleteCount} មិនទាន់រួច'
                          : '${group.notCompleteCount} Active',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isKm
                          ? '${group.doneCount} បានបញ្ចប់'
                          : '${group.doneCount} Done',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Subject Title & Task Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedSubjectName(group.name),
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isDarkMode ? AppColors.white : AppColors.dark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isKm
                      ? '${group.totalHomeworkCount} កិច្ចការផ្ទះ'
                      : '${group.totalHomeworkCount} Homework Tasks',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Bottom Progress Bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isKm ? 'ដំណើការ' : 'Progress',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey,
                        fontSize: 10.5,
                      ),
                    ),
                    Text(
                      '${(group.overallProgress * 100).toInt()}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: group.color,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.grey[800] : const Color(0xFFEFF2F8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: constraints.maxWidth *
                              group.overallProgress.clamp(0.0, 1.0),
                          decoration: BoxDecoration(
                            color: group.color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. SINGLE SUBJECT VIEW: High-Polish Modern Subject Header Card
  // ===========================================================================
  Widget _buildSubjectDetailHeader(
    BuildContext context,
    ParentHomeworkTabViewController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isKm = Get.locale?.languageCode == 'km';
    final subjectName = controller.selectedSubject.value ?? '';
    final subjectColor = SubjectUi.color(subjectName);
    final subjectBg = SubjectUi.bgColor(subjectName);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[800]!
              : AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // Top Navigation Bar
          Row(
            children: [
              // Back Button Circle
              Bounceable(
                onTap: controller.backToSubjectList,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.grey[800] : const Color(0xFFF4F5F8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 17,
                    color: isDarkMode ? AppColors.white : AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Subject Icon Container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: subjectBg,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  SubjectUi.icon(subjectName),
                  size: 24,
                  color: subjectColor,
                ),
              ),
              const SizedBox(width: 12),

              // Subject Title & Total Assignments Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Get.locale?.languageCode == 'km'
                          ? 'កិច្ចការផ្ទះ ${_getLocalizedSubjectName(subjectName)}'
                          : '$subjectName Homework',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkMode ? AppColors.white : AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isKm
                          ? 'កិច្ចការសរុប ${controller.subjectAllCount}'
                          : '${controller.subjectAllCount} Assignments Total',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Mini Dashboard Pill Container (Done, Missing, Total Score)
          _buildSubjectMiniDashboardCard(context, controller),

          const SizedBox(height: 16),

          // 4 Status Filter Tabs Bar
          _buildFourStatusTabs(context, controller),
        ],
      ),
    );
  }

  // Mini-Dashboard Pill Card (Done, Missing, Total Score)
  Widget _buildSubjectMiniDashboardCard(
    BuildContext context,
    ParentHomeworkTabViewController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isKm = Get.locale?.languageCode == 'km';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : const Color(0xFFEFF2F6),
        ),
      ),
      child: Row(
        children: [
          // 1. Done Stat
          Expanded(
            child: _buildDashboardStatBox(
              icon: Icons.check_circle_rounded,
              value: '${controller.subjectDoneCount}',
              label: isKm ? 'បានបញ្ចប់' : 'Done',
              color: const Color(0xFF16A34A),
              bgColor: const Color(0xFFDCFCE7),
              isDarkMode: isDarkMode,
            ),
          ),

          Container(
            width: 1,
            height: 32,
            color: isDarkMode ? Colors.grey[750] : const Color(0xFFE2E8F0),
          ),

          // 2. Missing Stat
          Expanded(
            child: _buildDashboardStatBox(
              icon: Icons.warning_rounded,
              value: '${controller.subjectMissingCount}',
              label: isKm ? 'ហួសកំណត់' : 'Missing',
              color: const Color(0xFFEF4444),
              bgColor: const Color(0xFFFEE2E2),
              isDarkMode: isDarkMode,
            ),
          ),

          Container(
            width: 1,
            height: 32,
            color: isDarkMode ? Colors.grey[750] : const Color(0xFFE2E8F0),
          ),

          // 3. Total Score Stat
          Expanded(
            child: _buildDashboardStatBox(
              icon: Icons.star_rounded,
              value: controller.subjectTotalScore,
              label: isKm ? 'ពិន្ទុសរុប' : 'Total Score',
              color: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFEDE9FE),
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStatBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
    required bool isDarkMode,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: isDarkMode ? color.withValues(alpha: 0.2) : bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 13,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDarkMode ? AppColors.white : AppColors.dark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 4 Status Filter Tabs Bar inside 1 Subject View
  Widget _buildFourStatusTabs(
    BuildContext context,
    ParentHomeworkTabViewController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isKm = Get.locale?.languageCode == 'km';

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Obx(
        () => Row(
          children: [
            _buildTabItem(
              context,
              controller,
              index: 0,
              label:
                  '${isKm ? 'ទាំងអស់' : 'All'} (${controller.subjectAllCount})',
            ),
            _buildTabItem(
              context,
              controller,
              index: 1,
              label:
                  '${isKm ? 'បានបញ្ចប់' : 'Done'} (${controller.subjectDoneCount})',
              indicatorColor: const Color(0xFF16A34A),
            ),
            _buildTabItem(
              context,
              controller,
              index: 2,
              label:
                  '${isKm ? 'មិនទាន់រួច' : 'Active'} (${controller.subjectNotCompleteCount})',
              indicatorColor: const Color(0xFF2563EB),
            ),
            _buildTabItem(
              context,
              controller,
              index: 3,
              label:
                  '${isKm ? 'ហួសកំណត់' : 'Missing'} (${controller.subjectMissingCount})',
              indicatorColor: const Color(0xFFDC2626),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    ParentHomeworkTabViewController controller, {
    required int index,
    required String label,
    Color? indicatorColor,
  }) {
    final isSelected = controller.selectedTabIndex.value == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode ? Colors.grey[750] : AppColors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (indicatorColor != null && isSelected) ...[
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 11.5,
                    color: isSelected
                        ? (indicatorColor ?? AppColors.primary)
                        : (isDarkMode ? AppColors.grey : AppColors.hintColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleSubjectHomeworkSliver(
    BuildContext context,
    ParentHomeworkTabViewController controller,
  ) {
    final items = controller.filteredHomeworkList;

    if (items.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(context));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _buildHomeworkCardWithStatus(context, controller, item);
          },
          childCount: items.length,
        ),
      ),
    );
  }

  // Creative & Ultra-Clean Homework Assignment Card
  Widget _buildHomeworkCardWithStatus(
    BuildContext context,
    ParentHomeworkTabViewController controller,
    ParentHomeworkItem item,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isKm = Get.locale?.languageCode == 'km';

    return Bounceable(
      onTap: () => _showHomeworkDetailsBottomSheet(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDarkMode
                ? Colors.grey[800]!
                : AppColors.border.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Line: Subject Avatar, Category Tag, Status Pill, Three-Dots Menu
            Row(
              children: [
                // Subject Avatar Squircle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? item.iconBgColor.withValues(alpha: 0.2)
                        : item.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Category Tag
                Text(
                  _getLocalizedSubjectName(item.category).toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: item.iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),

                const Spacer(),

                // Status Badge Pill (e.g. មិនទាន់រួច, ហួសកំណត់, បានបញ្ចប់)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: item.statusTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Three-Dots Menu
                IconButton(
                  onPressed: () =>
                      _showHomeworkDetailsBottomSheet(context, item),
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.grey,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Assignment Title
            Text(
              item.title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                color: isDarkMode ? AppColors.white : AppColors.dark,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Subtitle Line: Teacher Name & Due Date
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  item.teacherName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('·',
                    style: TextStyle(
                        color: AppColors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                const Icon(
                  Icons.event_outlined,
                  size: 14,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.dueDate,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: item.status == ParentHomeworkStatus.missing
                          ? const Color(0xFFDC2626)
                          : AppColors.grey,
                      fontSize: 12.5,
                      fontWeight: item.status == ParentHomeworkStatus.missing
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Slender Animated Progress Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : const Color(0xFFEFF2F8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width:
                          constraints.maxWidth * item.progress.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        color: item.status == ParentHomeworkStatus.done
                            ? const Color(0xFF16A34A)
                            : (item.status == ParentHomeworkStatus.missing
                                ? const Color(0xFFDC2626)
                                : AppColors.primary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Badges Line: Score Pill, Priority Pill & Progress %
            Row(
              children: [
                // Score Badge Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.status == ParentHomeworkStatus.done
                        ? const Color(0xFFDCFCE7)
                        : (item.status == ParentHomeworkStatus.missing
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFF3E8FF)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getLocalizedScore(item.score),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: item.status == ParentHomeworkStatus.done
                          ? const Color(0xFF16A34A)
                          : (item.status == ParentHomeworkStatus.missing
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF7C3AED)),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),

                const Spacer(),

                // Progress % Complete
                Text(
                  isKm
                      ? 'សម្រេចបាន ${(item.progress * 100).toInt()}%'
                      : '${(item.progress * 100).toInt()}% Complete',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isKm = Get.locale?.languageCode == 'km';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isKm ? 'មិនមានកិច្ចការផ្ទះទេ' : 'No Homework Found',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isKm
                ? 'កិច្ចការផ្ទះរបស់សិស្សនឹងបង្ហាញនៅទីនេះ'
                : 'Student homework assignments will appear here',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showHomeworkDetailsBottomSheet(
    BuildContext context,
    ParentHomeworkItem item,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isKm = Get.locale?.languageCode == 'km';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedSubjectName(item.category).toUpperCase(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: item.iconColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color:
                                isDarkMode ? AppColors.white : AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: item.statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: item.statusTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 18),
              _buildDetailRow(
                icon: Icons.person_outline_rounded,
                label: isKm ? 'គ្រូបង្រៀន' : 'Teacher',
                value: item.teacherName,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                label: isKm ? 'ថ្ងៃផុតកំណត់' : 'Due Date',
                value: item.dueDate,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                icon: Icons.star_outline_rounded,
                label: isKm ? 'ពិន្ទុ' : 'Score',
                value: _getLocalizedScore(item.score),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                icon: Icons.show_chart_rounded,
                label: isKm ? 'ដំណើការ' : 'Progress',
                value: isKm
                    ? 'សម្រេចបាន ${(item.progress * 100).toInt()}%'
                    : '${(item.progress * 100).toInt()}% Completed',
                isDarkMode: isDarkMode,
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  isKm ? 'ការពិពណ៌នា' : 'Description',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                    color: isDarkMode ? AppColors.white : AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        isDarkMode ? Colors.grey[300] : const Color(0xFF334155),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
              ],
              if (item.teacherComment.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.grey[850] : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey[750]!
                          : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isKm
                                ? 'សារ / មតិយោបល់របស់គ្រូ'
                                : 'Message from Teacher',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDarkMode
                                  ? AppColors.white
                                  : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.teacherComment,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDarkMode
                              ? Colors.grey[200]
                              : const Color(0xFF14532D),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isKm ? 'បិទ' : 'Close',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grey),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDarkMode ? Colors.grey[400] : const Color(0xFF64748B),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
            color: isDarkMode ? AppColors.white : AppColors.dark,
          ),
        ),
      ],
    );
  }
}
