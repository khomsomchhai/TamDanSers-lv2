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
      subjectName:
          (json['subject_name'] ?? json['subjectName'] ?? '').toString(),
      day: (json['day'] ?? '').toString(),
      startTime: (json['start_time'] ?? json['startTime'] ?? '').toString(),
      endTime: (json['end_time'] ?? json['endTime'] ?? '').toString(),
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
}
