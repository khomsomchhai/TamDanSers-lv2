part of 'homework_view.dart';

enum HomeworkStatus {
  notDone,    // មិនទាន់ធ្វើ
  preparing,  // កំពុងរៀបចំ
  late,       // យឺតយ៉ាវ
  completed,  // បានបញ្ចប់
}

class HomeworkItem {
  final String subjectKey;  // Translation key (math, khmer_literature, etc.)
  final String teacherName;
  final HomeworkStatus status;
  final String date;        // Deadline for ongoing, submission date for completed
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  HomeworkItem({
    required this.subjectKey,
    required this.teacherName,
    required this.status,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class HomeworkViewController extends GetxController {
  // Selected tab index: 0 for Ongoing (កំពុងបន្ត), 1 for Completed (បានបញ្ចប់)
  final selectedTabIndex = 0.obs;

  final ongoingList = <HomeworkItem>[].obs;
  final completedList = <HomeworkItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void goBackToHome() {
    try {
      final dashboardController = Get.find<StudentDashboardViewController>();
      dashboardController.changeTab(0);
    } catch (e) {
      Get.back();
    }
  }

  void _loadMockData() {
    ongoingList.assignAll([
      HomeworkItem(
        subjectKey: 'math',
        teacherName: 'គ្រីម ថៃ',
        status: HomeworkStatus.notDone,
        date: '11-01-2026',
        icon: Icons.calculate_outlined,
        iconColor: const Color(0xff6763EB),
        iconBgColor: const Color(0xff6763EB).withValues(alpha: 0.12),
      ),
      HomeworkItem(
        subjectKey: 'khmer_literature',
        teacherName: 'សុខ ម៉ាលី',
        status: HomeworkStatus.notDone,
        date: '12-01-2026',
        icon: Icons.translate_rounded,
        iconColor: const Color(0xffC95EDB),
        iconBgColor: const Color(0xffC95EDB).withValues(alpha: 0.12),
      ),
      HomeworkItem(
        subjectKey: 'physics',
        teacherName: 'ចាន់ ណារ៉េត',
        status: HomeworkStatus.preparing,
        date: '14-01-2026',
        icon: Icons.science_outlined,
        iconColor: const Color(0xff10B981),
        iconBgColor: const Color(0xff10B981).withValues(alpha: 0.12),
      ),
      HomeworkItem(
        subjectKey: 'history',
        teacherName: 'ហេង ចិត្រា',
        status: HomeworkStatus.late,
        date: '04-01-2026',
        icon: Icons.menu_book_rounded,
        iconColor: const Color(0xffEF4444),
        iconBgColor: const Color(0xffEF4444).withValues(alpha: 0.12),
      ),
    ]);

    completedList.assignAll([
      HomeworkItem(
        subjectKey: 'math',
        teacherName: 'គ្រីម ថៃ',
        status: HomeworkStatus.completed,
        date: '08-01-2026',
        icon: Icons.calculate_outlined,
        iconColor: const Color(0xff6763EB),
        iconBgColor: const Color(0xff6763EB).withValues(alpha: 0.12),
      ),
      HomeworkItem(
        subjectKey: 'physics',
        teacherName: 'ចាន់ ណារ៉េត',
        status: HomeworkStatus.completed,
        date: '05-01-2026',
        icon: Icons.science_outlined,
        iconColor: const Color(0xff10B981),
        iconBgColor: const Color(0xff10B981).withValues(alpha: 0.12),
      ),
      HomeworkItem(
        subjectKey: 'geography',
        teacherName: 'ឡាយ គឹមហុង',
        status: HomeworkStatus.completed,
        date: '03-01-2026',
        icon: Icons.public_rounded,
        iconColor: const Color(0xffF59E0B),
        iconBgColor: const Color(0xffF59E0B).withValues(alpha: 0.12),
      ),
      HomeworkItem(
        subjectKey: 'khmer_literature',
        teacherName: 'សុខ ម៉ាលី',
        status: HomeworkStatus.completed,
        date: '30-12-2025',
        icon: Icons.translate_rounded,
        iconColor: const Color(0xffC95EDB),
        iconBgColor: const Color(0xffC95EDB).withValues(alpha: 0.12),
      ),
    ]);
  }
}