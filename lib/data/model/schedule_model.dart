class ScheduleModel {
  final int id;
  final String subjectName;
  final String day;
  final String startTime;
  final String endTime;

  ScheduleModel({
    required this.id,
    required this.subjectName,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: _asInt(json['id']) ?? 0,
      subjectName: _asString(json['subject_name'] ?? json['subjectName']),
      day: _asString(json['day']),
      startTime: _asString(json['start_time'] ?? json['startTime']),
      endTime: _asString(json['end_time'] ?? json['endTime']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String _asString(dynamic value) {
    return value?.toString() ?? '';
  }
}
