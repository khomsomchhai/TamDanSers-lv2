class AttendanceModel {
  final int id;
  final int studentId;
  final int scheduleId;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final String date;
  final String day;
  final String startTime;
  final String endTime;
  final String status;
  final String remark;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.scheduleId,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.date,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.remark,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: _asInt(json['id']) ?? 0,
      studentId: _asInt(json['student_id'] ?? json['studentId']) ?? 0,
      scheduleId: _asInt(json['schedule_id'] ?? json['scheduleId']) ?? 0,
      classId: _asInt(json['class_id'] ?? json['classId']) ?? 0,
      className: _asString(json['class_name'] ?? json['className']),
      subjectId: _asInt(json['subject_id'] ?? json['subjectId']) ?? 0,
      subjectName: _asString(json['subject_name'] ?? json['subjectName']),
      teacherId: _asInt(json['teacher_id'] ?? json['teacherId']) ?? 0,
      teacherName: _asString(json['teacher_name'] ?? json['teacherName']),
      date: _asString(json['date']),
      day: _asString(json['day']),
      startTime: _asString(json['start_time'] ?? json['startTime']),
      endTime: _asString(json['end_time'] ?? json['endTime']),
      status: _asString(json['status']),
      remark: _asString(json['remark']),
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
