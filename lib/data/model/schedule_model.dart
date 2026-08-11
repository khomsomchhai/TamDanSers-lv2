class ScheduleModel {
  final int id;
  final int classId;
  final String className;
  final String subjectName;
  final String day;
  final String startTime;
  final String endTime;
  final String teacherName;
  final String room;

  ScheduleModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.subjectName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.teacherName,
    required this.room,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: _asInt(json['id']) ?? 0,
      classId: _asInt(json['class_id'] ?? json['classId']) ?? 0,
      className: _asString(
          json['class_name'] ?? json['className'] ?? json['class'] ?? ''),
      subjectName: _asString(json['subject_name'] ?? json['subjectName']),
      day: _asString(json['day']),
      startTime: _asString(json['start_time'] ?? json['startTime']),
      endTime: _asString(json['end_time'] ?? json['endTime']),
      teacherName: _asString(
          json['teacher_name'] ?? json['teacherName'] ?? json['teacher']),
      room: _asString(json['room_name'] ??
          json['room'] ??
          json['classroom'] ??
          json['room_number']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'class_name': className,
      'subject_name': subjectName,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'teacher_name': teacherName,
      'room': room,
    };
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
