part of 'schedule_screen_view.dart';

class ScheduleScreenViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final selectedIndex = 0.obs;
  final scheduleList = <dynamic>[].obs;
  final isLoading = false.obs;
  final days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
  final Map<String, String> fullDayNames = {
    'Mon': 'Monday',
    'Tue': 'Tuesday',
    'Wed': 'Wednesday',
    'Thu': 'Thursday',
    'Fri': 'Friday',
    'Sat': 'Saturday',
  };
  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: 6, vsync: this);

    tabController.addListener(() {
      final newIndex = tabController.animation!.value.round();

      if (selectedIndex.value != newIndex) {
        selectedIndex.value = newIndex;
      }
    });
    getSchedule();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> getSchedule() async {
    isLoading.value = true;
    try {
      var response = await ScheduleApi().getSchedule();
      debugPrint(response.toString());
      scheduleList.value = response;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  List getSchedulesByDay(String day) {
    final fullDay = fullDayNames[day.substring(0, 3)] ?? day;
    return scheduleList
        .where((item) =>
            item['day'].toString().toLowerCase() == fullDay.toLowerCase())
        .toList();
  }

  String formatTime(String time){
    final parseTime = DateFormat('HH:mm').parse(time);
    return DateFormat('h:mm a').format(parseTime);
  }

  bool isMorning(String time){
    final parseTime = DateFormat('HH:mm').parse(time);
    return parseTime.hour < 12;
  }

  IconData getSubjectIcon(String subject) {
    switch (subject) {
      case 'Khmer':
        return Icons.translate;
      case 'Math':
        return Icons.calculate;
      case 'English':
        return Icons.menu_book;
      case 'Biology':
        return Icons.science;
      case 'Physical':
        return Icons.bolt;
      case 'Chemical':
        return Icons.biotech;
      case 'Social':
        return Icons.public;
      case 'History':
        return Icons.account_balance;
      case 'Earth Science':
        return Icons.language;
      case 'Geography':
        return Icons.map;
      case 'Earth':
        return Icons.public;
      default:
        return Icons.book;
    }
  }

  Color getSubjectColor(String subject) {
    switch (subject) {
      case 'Khmer':
        return const Color.fromARGB(255, 87, 8, 223); // violet
      case 'Math':
        return const Color(0xFF16A34A); // green
      case 'English':
        return const Color(0xFFEAB308); // yellow
      case 'Biology':
        return const Color(0xFF10B981); // emerald
      case 'Physical':
        return const Color(0xFF2563EB); // blue
      case 'Chemical':
        return const Color(0xFFF97316); // orange
      case 'Social':
        return const Color(0xFFEC4899); // pink
      case 'History':
        return const Color(0xFFD97706); // amber
      case 'Earth Science':
        return const Color(0xFF06B6D4); // cyan
      case 'Geography':
        return const Color(0xFF14B8A6); // teal
      case 'Earth':
        return const Color(0xFF06B6D4);
      default:
        return Colors.grey;
    }
  }

  Color getSubjectBgColor(String subject) {
    switch (subject) {
      case 'Khmer':
        return const Color(0xFFF3E8FF);
      case 'Math':
        return const Color(0xFFDCFCE7);
      case 'English':
        return const Color(0xFFFEF9C3);
      case 'Biology':
        return const Color(0xFFD1FAE5);
      case 'Physical':
        return const Color(0xFFDBEAFE);
      case 'Chemical':
        return const Color(0xFFFFEDD5);
      case 'Social':
        return const Color(0xFFFCE7F3);
      case 'History':
        return const Color(0xFFFEF3C7);
      case 'Earth Science':
        return const Color(0xFFCFFAFE);
      case 'Geography':
        return const Color(0xFFCCFBF1);
      case 'Earth':
        return const Color(0xFFCFFAFE);
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}
