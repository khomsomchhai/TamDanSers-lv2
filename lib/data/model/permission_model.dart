class PermissionModel {
  final int id;
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

  final bool attendanceSaved;
  final bool canEdit;
  final bool canDelete;

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
    required this.attendanceSaved,
    required this.canEdit,
    required this.canDelete,
  });

  factory PermissionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final schedule = _asMap(
      json['schedule'],
    );

    return PermissionModel(
      id: _asInt(json['id']) ?? 0,

      requestType: _asString(
        json['request_type'] ??
            json['requestType'],
      ),

      scheduleId: _asInt(
        json['schedule_id'] ??
            json['scheduleId'] ??
            schedule['id'],
      ),

      type: _asString(json['type']),

      subjectName: _asString(
        json['subject_name'] ??
            json['subjectName'] ??
            schedule['subject_name'] ??
            schedule['subjectName'],
      ),

      day: _asString(
        json['day'] ??
            schedule['day'],
      ),

      startTime: _asString(
        json['start_time'] ??
            schedule['start_time'],
      ),

      endTime: _asString(
        json['end_time'] ??
            schedule['end_time'],
      ),

      reason: _asString(
        json['reason'],
      ),

      status: _asString(
        json['status'],
      ),

      createdAt: (
        json['created_at'] ??
            json['createdAt']
      )?.toString(),

      attendanceSaved:
          json['attendance_saved'] == true,

      canEdit:
          json['can_edit'] == true,

      canDelete:
          json['can_delete'] == true,
    );
  }

  static int? _asInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  static String _asString(
    dynamic value,
  ) {
    return value?.toString() ?? '';
  }

  static Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return <String, dynamic>{};
  }
}