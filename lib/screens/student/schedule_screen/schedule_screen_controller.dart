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

  final dayLabels = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
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

    tabController = TabController(
      length: days.length,
      vsync: this,
    );

    tabController.addListener(() {
      selectedIndex.value = tabController.index;
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
      final response = await ScheduleApi().getSchedule();
      scheduleList.value = response;
    } finally {
      isLoading.value = false;
    }
  }

  List getSchedulesByDay(String day) {
    final fullDay = fullDayNames[day] ?? day;

    return scheduleList.where((item) {
      return item['day']
              .toString()
              .toLowerCase() ==
          fullDay.toLowerCase();
    }).toList();
  }

  String formatTime(String time) {
    final parsed = DateFormat('HH:mm').parse(time);
    return DateFormat('h:mm a').format(parsed);
  }

  bool isMorning(String time) {
    final parsed = DateFormat('HH:mm').parse(time);
    return parsed.hour < 12;
  }
}
