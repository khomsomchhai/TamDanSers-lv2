import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';

import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';

import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/api/services/result_api.dart';
import 'package:tamdansers_lv2/core/api/services/schedule_api.dart';

import 'package:tamdansers_lv2/core/widgets/header/custom_header.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_action.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_placeholder.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';

import 'package:tamdansers_lv2/data/model/attendance_model.dart';
import 'package:tamdansers_lv2/data/model/parent_model.dart';
import 'package:tamdansers_lv2/data/model/schedule_model.dart';
import 'package:tamdansers_lv2/data/model/score_model.dart';
import 'package:tamdansers_lv2/data/model/student_model.dart';

import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_attendance_tab/parent_attendance_tab_controller.dart';

part 'parent_home_tab_binding.dart';
part 'parent_home_tab_controller.dart';

class ParentHomeTabView extends GetView<ParentHomeTabViewController> {
  const ParentHomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeaderContent(topPadding),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAttendanceProgressCard(context),
                      const SizedBox(height: 24),
                      buildTodayScheduleSection(),
                      const SizedBox(height: 24),
                      _buildRecentAttendance(),
                      const SizedBox(height: 24),
                      _buildAcademicProgressSection(),
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

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeaderContent(double topPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        topPadding + 12,
        16,
        22,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHeader(),
          const SizedBox(height: 16),
          Text(
            controller.getCurrentDate(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          _buildChildSection(),
          const SizedBox(height: 16),
          _buildTopHeaderScoreCards(),
          const SizedBox(height: 12),
          _buildResultSection(),
        ],
      ),
    );
  }

  // =====================================================
  // TOP SCORE CARDS
  // =====================================================

  Widget _buildTopHeaderScoreCards() {
    return Obx(() {
      final totalScore = controller.displayTotalScore;
      final rank = controller.displayRank;
      final average = controller.displayAverage;

      return Row(
        children: [
          Expanded(
            child: _buildBlueStatCard(
              title: 'ពិន្ទុសរុប',
              value: totalScore,
              icon: Icons.star_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBlueStatCard(
              title: 'ចំណាត់ថ្នាក់',
              value: rank,
              icon: Icons.emoji_events_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBlueStatCard(
              title: 'មធ្យមភាគ',
              value: average,
              icon: Icons.bar_chart_rounded,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBlueStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const CustomHeaderPlaceholder();
            }

            return CustomHeader(
              controller: controller.userController,
              textColor: AppColors.white,
            );
          }),
        ),
        const SizedBox(width: 12),
        const CustomHeaderAction(),
      ],
    );
  }

  // =====================================================
  // CHILD SECTION
  // =====================================================

  Widget _buildChildSection() {
    return Obx(() {
      if (controller.students.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.30),
            ),
          ),
          child: Text(
            'dont_have_child'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  '${'hello_parent'.tr} ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  controller.childName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 62,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: controller.selectedChild.value,
                isExpanded: true,
                menuMaxHeight: 300,
                dropdownColor: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.info,
                  size: 28,
                ),
                selectedItemBuilder: (context) {
                  return controller.students.map((student) {
                    return _buildSelectedChild(student);
                  }).toList();
                },
                items: controller.students.map((student) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: student,
                    child: _buildDropdownChild(student),
                  );
                }).toList(),
                onChanged: (child) {
                  if (child != null) {
                    controller.selectChild(child);
                  }
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSelectedChild(
    Map<String, dynamic> student,
  ) {
    final name = _getStudentName(student);
    final code = _getStudentCode(student);

    return Row(
      children: [
        _buildStudentAvatar(
          student,
          radius: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownChild(
    Map<String, dynamic> student,
  ) {
    final name = _getStudentName(student);
    final code = _getStudentCode(student);

    final selectedId = _parseStudentId(controller.selectedChild.value);

    final currentId = _parseStudentId(student);

    final isSelected =
        selectedId != null && currentId != null && selectedId == currentId;

    return SizedBox(
      height: 58,
      child: Row(
        children: [
          _buildStudentAvatar(
            student,
            radius: 19,
            isSelected: isSelected,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? AppColors.info : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.info,
              size: 20,
            ),
        ],
      ),
    );
  }

  String _getStudentName(
    Map<String, dynamic> student,
  ) {
    return student['student_name']?.toString() ??
        student['name']?.toString() ??
        student['full_name']?.toString() ??
        '-';
  }

  String _getStudentCode(
    Map<String, dynamic> student,
  ) {
    return student['student_code']?.toString() ??
        student['code']?.toString() ??
        '-';
  }

  // =====================================================
  // STUDENT AVATAR
  // =====================================================

  Widget _buildStudentAvatar(
    Map<String, dynamic> student, {
    double radius = 18,
    bool isSelected = false,
  }) {
    final name = _getStudentName(student);

    return Obx(() {
      final candidateUrls = _getStudentCandidateUrls(student);

      return _StudentAvatarWidget(
        candidateUrls: candidateUrls,
        radius: radius,
        isSelected: isSelected,
        headers: _getImageHeaders(),
        name: name,
      );
    });
  }

  // =====================================================
  // IMAGE HELPERS
  // =====================================================

  String _formatImageUrl(String url) {
    final cleanUrl = url.trim();

    if (cleanUrl.isEmpty || cleanUrl == 'null' || cleanUrl == 'None') {
      return '';
    }

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }

    const baseUrl = 'https://tamdansers-1fvbe1msgz9hki.sabay.com';

    final formattedPath = cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl';

    return '$baseUrl$formattedPath';
  }

  String _extractImageFromMap(dynamic data) {
    if (data == null) {
      return '';
    }

    if (data is StudentModel) {
      if (data.profileImage.isNotEmpty) {
        return _formatImageUrl(
          data.profileImage,
        );
      }

      return '';
    }

    if (data is String) {
      final value = data.trim();

      if (value.isNotEmpty && value != 'null') {
        return _formatImageUrl(value);
      }

      return '';
    }

    if (data is Map) {
      const knownKeys = [
        'profile_image',
        'profileImage',
        'profile_photo',
        'student_image',
        'studentImage',
        'avatar_url',
        'avatarUrl',
        'avatar',
        'photo_url',
        'photoUrl',
        'image',
        'image_url',
        'imageUrl',
      ];

      for (final key in knownKeys) {
        if (data.containsKey(key) && data[key] != null) {
          final value = data[key].toString().trim();

          if (value.isNotEmpty && value != 'null') {
            return _formatImageUrl(value);
          }
        }
      }

      // Nested student object
      if (data['student'] != null) {
        return _extractImageFromMap(
          data['student'],
        );
      }
    }

    return '';
  }

  int? _parseStudentId(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is Map) {
      final raw = value['id'] ?? value['student_id'] ?? value['studentId'];

      if (raw != null) {
        final parsed = _parseStudentId(raw);

        if (parsed != null) {
          return parsed;
        }
      }

      // Handle nested student object
      if (value['student'] != null) {
        return _parseStudentId(
          value['student'],
        );
      }
    }

    return int.tryParse(
      value.toString(),
    );
  }

  List<String> _getStudentCandidateUrls(
    Map<String, dynamic> student,
  ) {
    final urls = <String>[];

    final directUrl = _extractImageFromMap(student);

    if (directUrl.isNotEmpty) {
      urls.add(directUrl);
    }

    final id = _parseStudentId(student);

    if (id != null && controller.studentImages.containsKey(id)) {
      final cachedUrl = controller.studentImages[id];

      if (cachedUrl != null) {
        final formatted = _formatImageUrl(
          cachedUrl.toString(),
        );

        if (formatted.isNotEmpty) {
          urls.add(formatted);
        }
      }
    }

    final dashboard = controller.dashboard.value;

    if (dashboard != null) {
      final dashboardStudentId = _parseStudentId(
        dashboard.student,
      );

      if (id != null &&
          dashboardStudentId != null &&
          id == dashboardStudentId) {
        final dashboardUrl = _formatImageUrl(
          dashboard.student.profileImage,
        );

        if (dashboardUrl.isNotEmpty) {
          urls.add(dashboardUrl);
        }
      }
    }

    return urls
        .where(
          (url) => url.trim().isNotEmpty,
        )
        .toSet()
        .toList();
  }

  Map<String, String>? _getImageHeaders() {
    final token = GetStorage().read('token');

    if (token != null && token.toString().trim().isNotEmpty) {
      return {
        'Authorization': 'Bearer ${token.toString().trim()}',
      };
    }

    return null;
  }

  // =====================================================
  // ATTENDANCE PROGRESS
  // =====================================================

  Widget _buildAttendanceProgressCard(
    BuildContext context,
  ) {
    return Obx(() {
      final attendanceController = controller.attendanceController;

      if (attendanceController.isLoading.value &&
          attendanceController.attendanceList.isEmpty) {
        return const SizedBox.shrink();
      }

      final rate = attendanceController.attendanceRate;

      final percentValue = (rate / 100.0).clamp(0.0, 1.0);

      final totalDays = attendanceController.totalDays;

      final presentDays = attendanceController.presentDays.value;

      final absentDays = attendanceController.absentDays.value;

      final permissionDays = attendanceController.permissionDays.value;

      final isKm = Get.locale?.languageCode == 'km';

      final monthDisplay = attendanceController.currentMonthName;

      final titleText = isKm ? 'វត្តមានប្រចាំខែ' : 'Monthly Attendance';

      final totalDaysText = isKm
          ? 'សរុប $totalDays ថ្ងៃ'
          : 'Total $totalDays ${totalDays == 1 ? 'Day' : 'Days'}';

      final attendanceBtnText =
          isKm ? 'វត្តមាន ខែ$monthDisplay' : '$monthDisplay Attendance';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.04,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0EDFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        size: 26,
                        color: Color(0xFF0F4C5C),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.dark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            monthDisplay,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.dark,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            totalDaysText,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.hintColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${rate.toStringAsFixed(0)}%',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentValue,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF046A38),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  onTap: () => _showMonthPickerBottomSheet(
                    context,
                    attendanceController,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCEBFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 19,
                          color: Color(0xFF0F4C5C),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          attendanceBtnText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color(0xFF0F4C5C),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Color(0xFF0F4C5C),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHomeStatSquareCard(
                  mainTitle: isKm ? 'វត្តមាន' : 'Present',
                  count: presentDays,
                  unit: isKm ? 'ថ្ងៃ' : (presentDays == 1 ? 'Day' : 'Days'),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFF0FDF4),
                  borderColor: const Color(0xFFDCFCE7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHomeStatSquareCard(
                  mainTitle: isKm ? 'អវត្តមាន' : 'Absent',
                  count: absentDays,
                  unit: isKm ? 'ថ្ងៃ' : (absentDays == 1 ? 'Day' : 'Days'),
                  icon: Icons.cancel_rounded,
                  color: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEF2F2),
                  borderColor: const Color(0xFFFEE2E2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHomeStatSquareCard(
                  mainTitle: isKm ? 'សុំច្បាប់' : 'Leave',
                  count: permissionDays,
                  unit: isKm ? 'ថ្ងៃ' : (permissionDays == 1 ? 'Day' : 'Days'),
                  icon: Icons.assignment_rounded,
                  color: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFFEF3C7),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildHomeStatSquareCard({
    required String mainTitle,
    required int count,
    required String unit,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  mainTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.dark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: AppColors.hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MONTH PICKER
  // =====================================================

  void _showMonthPickerBottomSheet(
    BuildContext context,
    ParentAttendanceTabViewController attendanceController,
  ) {
    final isKm = Get.locale?.languageCode == 'km';

    const khmerMonths = [
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
      'ធ្នូ',
    ];

    const englishMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final months = isKm ? khmerMonths : englishMonths;

    Get.bottomSheet(
      Obx(() {
        final currentSelected = attendanceController.selectedMonth.value;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isKm ? 'ជ្រើសរើសខែ' : 'Select Month',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.dark,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final monthNum = index + 1;

                  final isSelected = monthNum == currentSelected;

                  return InkWell(
                    onTap: () {
                      attendanceController.changeMonth(
                        monthNum,
                      );
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(
                          14,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                      ),
                      child: Text(
                        months[index],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? AppColors.white : AppColors.dark,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  // =====================================================
  // RECENT ATTENDANCE
  // =====================================================

  Widget _buildRecentAttendance() {
    return Obx(() {
      final attendanceController = controller.attendanceController;

      final now = DateTime.now();

      final todayAttendance =
          attendanceController.attendanceList.where((attendance) {
        final date = DateTime.tryParse(
          attendance.date,
        );

        if (date == null) {
          return false;
        }

        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }).toList();

      todayAttendance.sort((a, b) {
        return _timeToMinutes(
          a.startTime,
        ).compareTo(
          _timeToMinutes(
            b.startTime,
          ),
        );
      });

      if (attendanceController.isLoading.value && todayAttendance.isEmpty) {
        return const SizedBox.shrink();
      }

      if (todayAttendance.isEmpty) {
        return _buildAttendanceEmptyState();
      }

      final canExpand = todayAttendance.length > 2;

      final isExpanded = controller.isAttendanceExpanded.value;

      final visibleItems =
          isExpanded ? todayAttendance : todayAttendance.take(2).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'attendance_today'.tr,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.dark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (canExpand)
                InkWell(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  onTap: controller.toggleAttendanceExpanded,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'បង្ហាញតិច' : 'មើលទាំងអស់',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(
              milliseconds: 250,
            ),
            curve: Curves.easeInOut,
            child: Column(
              children: visibleItems.map(
                (attendance) {
                  return _buildHomeAttendanceItem(
                    attendance,
                  );
                },
              ).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHomeAttendanceItem(
    AttendanceModel attendance,
  ) {
    final attendanceController = controller.attendanceController;

    final statusColor = attendanceController.getStatusColor(
      attendance.status,
    );

    final statusText = attendanceController.getStatusText(
      attendance.status,
    );

    final subjectName = attendance.subjectName.trim().isEmpty
        ? '-'
        : attendance.subjectName.trim();

    final className =
        attendance.className.trim().isEmpty ? '-' : attendance.className.trim();

    final teacherName = attendance.teacherName.trim().isEmpty
        ? '-'
        : attendance.teacherName.trim();

    final remark = attendance.remark.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 27,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(
                width: 13,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$subjectName - $className',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.dark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${'teacher'.tr}: $teacherName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    22,
                  ),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  attendanceController.formatDate(
                    attendance.date,
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ),
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: 7),
              Text(
                _formatTimeRange(
                  attendance.startTime,
                  attendance.endTime,
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          if (remark.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 17,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    remark,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'attendance_today'.tr,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 38,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_outlined,
                  size: 35,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              Text(
                'មិនមានទិន្នន័យវត្តមានថ្ងៃនេះ',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'ទិន្នន័យវត្តមានថ្ងៃនេះនឹងបង្ហាញនៅទីនេះ',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // RESULT SECTION
  // =====================================================

  Widget _buildResultSection() {
    return Obx(() {
      final selectedType = controller.selectedResultType.value;

      final selectedSub = controller.selectedSubResult.value;

      final isExpanded = controller.isResultExpanded.value;

      final subOptions = controller.currentSubOptions;

      return Column(
        children: [
          InkWell(
            onTap: controller.isResultExpanded.toggle,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(
                  14,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    size: 19,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'លទ្ធផល $selectedType • $selectedSub',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                  16,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.04,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: controller.resultTypes.map((type) {
                        final isTypeSelected = type == selectedType;

                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 6,
                          ),
                          child: InkWell(
                            onTap: () => controller.selectResultType(
                              type,
                            ),
                            borderRadius: BorderRadius.circular(
                              14,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 150,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isTypeSelected
                                    ? AppColors.primary
                                    : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(
                                  14,
                                ),
                                border: Border.all(
                                  color: isTypeSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: isTypeSelected
                                      ? Colors.white
                                      : AppColors.dark,
                                  fontWeight: isTypeSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ជ្រើសរើស $selectedType:',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedType == 'ប្រចាំខែ')
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subOptions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemBuilder: (context, index) {
                        final monthName = subOptions[index];

                        final isSubSelected = monthName == selectedSub;

                        return InkWell(
                          onTap: () => controller.selectSubResult(
                            monthName,
                          ),
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 150,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSubSelected
                                  ? AppColors.primary
                                  : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              border: Border.all(
                                color: isSubSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              monthName,
                              style: TextStyle(
                                color: isSubSelected
                                    ? Colors.white
                                    : AppColors.dark,
                                fontWeight: isSubSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: subOptions.map(
                        (opt) {
                          final isSubSelected = opt == selectedSub;

                          return InkWell(
                            onTap: () => controller.selectSubResult(
                              opt,
                            ),
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 150,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: isSubSelected
                                    ? AppColors.primary
                                    : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                                border: Border.all(
                                  color: isSubSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    opt,
                                    style: TextStyle(
                                      color: isSubSelected
                                          ? Colors.white
                                          : AppColors.dark,
                                      fontWeight: isSubSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (isSubSelected) ...[
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  // =====================================================
  // TODAY SCHEDULE
  // =====================================================

  Widget buildTodayScheduleSection() {
    return Obx(() {
      if (controller.isScheduleLoading.value) {
        return _buildScheduleLoading();
      }

      if (controller.scheduleError.value.isNotEmpty) {
        return _buildScheduleError();
      }

      if (controller.todaySchedule.isEmpty) {
        return _buildScheduleEmpty();
      }

      final totalSessions = controller.todaySchedule.length;

      final sessionText = Get.locale?.languageCode == 'km'
          ? '$totalSessions វគ្គ'
          : '$totalSessions session';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'today_schedule'.tr,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.dark,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.20,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.class_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      sessionText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...controller.todaySchedule.map(scheduleCard),
        ],
      );
    });
  }

  Widget _buildScheduleLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'កាលវិភាគថ្ងៃនេះ',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          2,
          (index) {
            return Container(
              width: double.infinity,
              height: 135,
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'កាលវិភាគថ្ងៃនេះ',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 32,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ថ្ងៃនេះមិនមានកាលវិភាគទេ',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'កាលវិភាគសិក្សាប្រចាំថ្ងៃនឹងបង្ហាញនៅទីនេះ',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.error.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 36,
            color: AppColors.error,
          ),
          const SizedBox(height: 10),
          Text(
            'មិនអាចទាញយកកាលវិភាគបាន',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              final studentId = controller.selectedChild.value?['id'];

              final parsedId = _parseStudentId(
                studentId,
              );

              if (parsedId != null) {
                controller.getTodaySchedule(
                  parsedId,
                );
              }
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'ព្យាយាមម្ដងទៀត',
            ),
          ),
        ],
      ),
    );
  }

  Widget scheduleCard(
    ScheduleModel item,
  ) {
    final subject =
        item.subjectName.trim().isEmpty ? '-' : item.subjectName.trim();

    final teacher =
        item.teacherName.trim().isEmpty ? '-' : item.teacherName.trim();

    final isMorning = controller.isMorning(
      item.startTime,
    );

    final subjectColor = SubjectUi.color(subject);

    final subjectBg = SubjectUi.bgColor(subject);

    final iconData = SubjectUi.icon(subject);

    final periodLabel = isMorning ? 'morning'.tr : 'afternoon'.tr;

    final periodBg = isMorning
        ? AppColors.primary.withValues(
            alpha: 0.10,
          )
        : const Color(0xFF0891B2).withValues(
            alpha: 0.10,
          );

    final periodColor = isMorning ? AppColors.primary : const Color(0xFF0891B2);

    final roomName = item.room.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.7,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: subjectColor.withValues(
              alpha: 0.08,
            ),
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
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: subjectColor,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: subjectBg,
                              borderRadius: BorderRadius.circular(
                                16,
                              ),
                            ),
                            child: Icon(
                              iconData,
                              color: subjectColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.dark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '${'teacher'.tr}: $teacher',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.hintColor,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: periodBg,
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              periodLabel,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: periodColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: subjectColor.withValues(
                            alpha: 0.07,
                          ),
                          borderRadius: BorderRadius.circular(
                            14,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 17,
                              color: subjectColor,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                '${controller.formatTime(item.startTime)} - ${controller.formatTime(item.endTime)}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: subjectColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            if (roomName.isNotEmpty)
                              Text(
                                roomName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: subjectColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
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

// =====================================================
// ACADEMIC PROGRESS SECTION
// WITH COLLAPSED CARD VIEW
// =====================================================
  Widget _buildAcademicProgressSection() {
    return Obx(() {
      final isExpanded = controller.isAcademicProgressExpanded.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =================================================
          // SECTION HEADER
          // =================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'លទ្ធផលសិក្សា',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.dark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: controller.toggleAcademicProgressExpanded,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isExpanded ? 'លាក់' : 'បង្ហាញ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // =================================================
          // EXPAND / COLLAPSE
          // =================================================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildAcademicResultCard(),
            secondChild: _buildCollapsedAcademicCard(),
          ),
        ],
      );
    });
  }

// =====================================================
// COMPACT CARD
// DISPLAYED WHEN COLLAPSED / "លាក់"
// =====================================================
  Widget _buildCollapsedAcademicCard() {
    return Obx(() {
      final selectedType = controller.selectedResultType.value;

      final selectedSub = controller.selectedSubResult.value;

      return InkWell(
        onTap: controller.toggleAcademicProgressExpanded,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // =================================================
              // ICON
              // =================================================
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // =================================================
              // TITLE + FILTER
              // =================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'លទ្ធផលសិក្សា',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.dark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'របាយការណ៍សង្ខេប '
                      '$selectedType • $selectedSub',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.hintColor,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.hintColor,
              ),
            ],
          ),
        ),
      );
    });
  }

// =====================================================
// FULL ACADEMIC RESULT CARD
// =====================================================
  Widget _buildAcademicResultCard() {
    return Obx(() {
      final selectedType = controller.selectedResultType.value;

      final selectedSub = controller.selectedSubResult.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // HEADER
            // =================================================
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'លទ្ធផលសិក្សា',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.dark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'របាយការណ៍សង្ខេប '
                        '$selectedType • $selectedSub',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.hintColor,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.hintColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // =================================================
            // SCORE GRAPH
            // =================================================
            _buildScoreLevelGraphBox(),

            const SizedBox(height: 14),

            // =================================================
            // STRENGTHS + IMPROVEMENTS
            // =================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // STRENGTHS
                // =================================================
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFDCFCE7),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              size: 16,
                              color: Color(0xFF16A34A),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'ចំណុចខ្លាំង',
                              style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...controller.strengthsList.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 3,
                            ),
                            child: Text(
                              '• $item',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF15803D),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // =================================================
                // IMPROVEMENTS
                // =================================================
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFEF3C7),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.track_changes_rounded,
                              size: 16,
                              color: Color(0xFFD97706),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'ចំណុចត្រូវកែលម្អ',
                              style: TextStyle(
                                color: Color(0xFFD97706),
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...controller.improvementsList.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 3,
                            ),
                            child: Text(
                              '• $item',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // =================================================
            // VIEW DETAIL BUTTON
            // =================================================
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.viewStudentResultDetail);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'មើលរបាយការណ៍លម្អិត',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

// =====================================================
// SCORE LEVEL GRAPH BOX
//
// IMPORTANT FIX:
// Use selectedSubResult as the source of truth.
//
// Example:
// selectedSubResult = "ខែធ្នូ"
//
// The graph becomes:
//
// កញ្ញា | តុលា | វិច្ឆិកា | ធ្នូ
//                              ↑
//                             39
//
// The graph does NOT use attendanceController.selectedMonth
// anymore.
// =====================================================
  Widget _buildScoreLevelGraphBox() {
    final type = controller.selectedResultType.value;

    final sub = controller.selectedSubResult.value;

    final averageScore = controller.displayAverage;

    List<Widget> items = [];

    // =====================================================
    // MONTHLY
    // =====================================================
    if (type == 'ប្រចាំខែ') {
      const khmerMonths = [
        'ខែមករា',
        'ខែកុម្ភៈ',
        'ខែមីនា',
        'ខែមេសា',
        'ខែឧសភា',
        'ខែមិថុនា',
        'ខែកក្កដា',
        'ខែសីហា',
        'ខែកញ្ញា',
        'ខែតុលា',
        'ខែវិច្ឆិកា',
        'ខែធ្នូ',
      ];

      const khmerShortMonths = [
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
        'ធ្នូ',
      ];

      // ===================================================
      // FIND SELECTED MONTH FROM selectedSubResult
      //
      // Examples:
      //
      // "ខែធ្នូ"    -> 11
      // "ខែសីហា"   -> 7
      // "ខែមករា"   -> 0
      // ===================================================
      int selectedIdx = khmerMonths.indexOf(sub);

      // ===================================================
      // FALLBACK
      //
      // In case selectedSubResult is already a short month:
      //
      // "ធ្នូ" -> 11
      // "សីហា" -> 7
      // ===================================================
      if (selectedIdx < 0) {
        selectedIdx = khmerShortMonths.indexOf(sub);
      }

      // ===================================================
      // FALLBACK FOR "ខែ" PREFIX
      //
      // Example:
      // "ខែធ្នូ" -> "ធ្នូ"
      // ===================================================
      if (selectedIdx < 0) {
        final cleanSub = sub.replaceAll('ខែ', '').trim();

        selectedIdx = khmerShortMonths.indexOf(cleanSub);
      }

      // ===================================================
      // FINAL FALLBACK
      //
      // If nothing matches, use current month.
      // ===================================================
      if (selectedIdx < 0) {
        selectedIdx = DateTime.now().month - 1;
      }

      // Make sure index is always valid.
      selectedIdx = selectedIdx.clamp(0, 11);

      // ===================================================
      // DISPLAY 4 MONTHS
      //
      // Example:
      // selected = December
      //
      // កញ្ញា | តុលា | វិច្ឆិកា | ធ្នូ
      //
      // Example:
      // selected = August
      //
      // ឧសភា | មិថុនា | កក្កដា | សីហា
      // ===================================================
      final displayShortMonths = [
        khmerShortMonths[(selectedIdx - 3 + 12) % 12],
        khmerShortMonths[(selectedIdx - 2 + 12) % 12],
        khmerShortMonths[(selectedIdx - 1 + 12) % 12],
        khmerShortMonths[selectedIdx],
      ];

      // ===================================================
      // BUILD GRAPH ITEMS
      // ===================================================
      items = displayShortMonths.map((month) {
        final isSelected = month == khmerShortMonths[selectedIdx];

        return _buildGraphItem(
          month,
          isSelected ? averageScore : '',
          isSelected,
        );
      }).toList();
    }

    // =====================================================
    // SEMESTER
    // =====================================================
    else if (type.contains('ឆមាស')) {
      const semesters = [
        'ឆមាស ១',
        'ឆមាស ២',
      ];

      items = semesters.map((semester) {
        final isSelected =
            sub.contains('២') ? semester == 'ឆមាស ២' : semester == 'ឆមាស ១';

        return _buildGraphItem(
          semester,
          isSelected ? averageScore : '',
          isSelected,
        );
      }).toList();
    }

    // =====================================================
    // YEARLY
    // =====================================================
    else {
      final currentYearLabel = 'ឆ្នាំ ${DateTime.now().year}';

      items = [
        _buildGraphItem(
          currentYearLabel,
          averageScore,
          true,
        ),
      ];
    }

    // =====================================================
    // GRAPH CONTAINER
    // =====================================================
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =================================================
          // GRAPH HEADER
          // =================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'កម្រិតពិន្ទុមធ្យម',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.hintColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'មធ្យមភាគ: $averageScore',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // =================================================
          // GRAPH ITEMS
          // =================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items,
          ),
        ],
      ),
    );
  }

// =====================================================
// GRAPH ITEM
//
// Selected:
//
//      ┌──────┐
//      │  39  │
//      └──────┘
//        ធ្នូ
//
// Not selected:
//
//        កញ្ញា
// =====================================================
  Widget _buildGraphItem(
    String label,
    String value,
    bool isHighlighted,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // =================================================
        // SCORE PILL
        // =================================================
        if (isHighlighted && value.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          // Keep exactly the same vertical space
          // when there is no score.
          const SizedBox(height: 24),

        const SizedBox(height: 6),

        // =================================================
        // MONTH / SEMESTER / YEAR LABEL
        // =================================================
        Text(
          label,
          style: TextStyle(
            color: isHighlighted ? AppColors.primary : AppColors.hintColor,
            fontSize: 12,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // TIME HELPERS
  // =====================================================

  String _formatTimeRange(
    String startTime,
    String endTime,
  ) {
    final start = _formatTime(startTime);

    final end = _formatTime(endTime);

    if (start.isEmpty && end.isEmpty) {
      return '-';
    }

    if (start.isEmpty) {
      return end;
    }

    if (end.isEmpty) {
      return start;
    }

    return '$start - $end';
  }

  String _formatTime(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return '';
    }

    final parts = text.split(':');

    if (parts.length < 2) {
      return text;
    }

    final hour = parts[0].padLeft(
      2,
      '0',
    );

    final minute = parts[1].padLeft(
      2,
      '0',
    );

    return '$hour:$minute';
  }

  int _timeToMinutes(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return 0;
    }

    final parts = text.split(':');

    if (parts.length < 2) {
      return 0;
    }

    final hour = int.tryParse(parts[0]) ?? 0;

    final minute = int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }
}

// =====================================================
// LOCAL STUDENT AVATAR WIDGET
// THIS FIXES:
// "StudentAvatarWidget isn't defined"
// =====================================================

class _StudentAvatarWidget extends StatefulWidget {
  final List<String> candidateUrls;
  final double radius;
  final bool isSelected;
  final Map<String, String>? headers;
  final String name;

  const _StudentAvatarWidget({
    required this.candidateUrls,
    required this.radius,
    required this.isSelected,
    required this.headers,
    required this.name,
  });

  @override
  State<_StudentAvatarWidget> createState() => _StudentAvatarWidgetState();
}

class _StudentAvatarWidgetState extends State<_StudentAvatarWidget> {
  int _currentUrlIndex = 0;

  @override
  void didUpdateWidget(
    covariant _StudentAvatarWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.candidateUrls != widget.candidateUrls) {
      _currentUrlIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;

    final borderColor = widget.isSelected ? AppColors.info : Colors.white;

    final imageUrl = widget.candidateUrls.isNotEmpty &&
            _currentUrlIndex < widget.candidateUrls.length
        ? widget.candidateUrls[_currentUrlIndex]
        : '';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(
          alpha: 0.10,
        ),
        border: Border.all(
          color: borderColor,
          width: widget.isSelected ? 2 : 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? _buildInitialAvatar()
          : Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              headers: widget.headers,
              errorBuilder: (context, error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                    if (!mounted) {
                      return;
                    }

                    if (_currentUrlIndex < widget.candidateUrls.length - 1) {
                      setState(() {
                        _currentUrlIndex++;
                      });
                    } else {
                      setState(() {});
                    }
                  },
                );

                return _buildInitialAvatar();
              },
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return _buildLoadingAvatar();
              },
            ),
    );
  }

  Widget _buildInitialAvatar() {
    final initial = widget.name.trim().isEmpty
        ? '?'
        : widget.name.trim().characters.first.toUpperCase();

    return Container(
      color: AppColors.primary.withValues(
        alpha: 0.10,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: widget.radius * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      color: AppColors.primary.withValues(
        alpha: 0.06,
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: widget.radius * 0.65,
        height: widget.radius * 0.65,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
