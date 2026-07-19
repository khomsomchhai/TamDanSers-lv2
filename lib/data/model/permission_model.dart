class PermissionModel {
  final dynamic id;
  final String requestType;
  final int? scheduleId;
  final String type;
  final String subjectName;
  final String day;
  final String startTime;
  final String endTime;
  final String reason;
  final String status;
  final String? createdAt;

  PermissionModel({
    required this.id,
    required this.requestType,
    this.scheduleId,
    required this.type,
    required this.subjectName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    final schedule = json['schedule'] is Map<String, dynamic>
        ? json['schedule'] as Map<String, dynamic>
        : <String, dynamic>{};

    return PermissionModel(
      id: json['id'],
      requestType:
          (json['request_type'] ?? json['requestType'] ?? '').toString(),
      scheduleId:
          _asInt(json['schedule_id'] ?? json['scheduleId'] ?? schedule['id']),
      type: (json['type'] ?? '').toString(),
      subjectName: (json['subject_name'] ??
              json['subjectName'] ??
              schedule['subject_name'] ??
              schedule['subjectName'] ??
              '')
          .toString(),
      day: (json['day'] ?? schedule['day'] ?? '').toString(),
      startTime:
          (json['start_time'] ?? schedule['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? schedule['end_time'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['createdAt'])?.toString(),
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
