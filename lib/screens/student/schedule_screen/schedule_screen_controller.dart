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

  DateTime? _parseTime(String time) {
    try {
      return DateFormat('HH:mm').parse(time);
    } catch (_) {
      return null;
    }
  }

  int _compareTime(String? a, String? b) {
    final first = _parseTime(a ?? '');
    final second = _parseTime(b ?? '');

    if (first == null && second == null) return 0;
    if (first == null) return 1;
    if (second == null) return -1;
    return first.compareTo(second);
  }

  List getSchedulesByDay(String day) {
    final fullDay = fullDayNames[day] ?? day;

    final schedules = scheduleList.where((item) {
      return item['day']
              .toString()
              .toLowerCase() ==
          fullDay.toLowerCase();
    }).toList();

    return sortSchedulesByTime(schedules);
  }

  List sortSchedulesByTime(List schedules) {
    final sorted = List<dynamic>.from(schedules);
    sorted.sort((a, b) {
      final compareStart = _compareTime(a['start_time']?.toString(), b['start_time']?.toString());
      if (compareStart != 0) return compareStart;
      return _compareTime(a['end_time']?.toString(), b['end_time']?.toString());
    });
    return sorted;
  }

  String formatTime(String time) {
    final parsed = _parseTime(time);
    if (parsed == null) return time;
    return DateFormat('h:mm a').format(parsed);
  }

  String formatTimeRange(String start, String end) {
    final parsedStart = _parseTime(start);
    final parsedEnd = _parseTime(end);
    if (parsedStart == null || parsedEnd == null) {
      return '$start - $end';
    }

    final startLabel = DateFormat('h:mm a').format(parsedStart);
    final endPeriod = DateFormat('a').format(parsedEnd);
    final startPeriod = DateFormat('a').format(parsedStart);

    if (startPeriod == endPeriod) {
      final endLabel = DateFormat('h:mm a').format(parsedEnd);
      return '$startLabel - $endLabel';
    }

    final endLabel = DateFormat('h:mm a').format(parsedEnd);
    return '$startLabel - $endLabel';
  }

  bool isMorning(String time) {
    final parsed = _parseTime(time);
    if (parsed == null) return false;
    return parsed.hour < 12;
  }
}
