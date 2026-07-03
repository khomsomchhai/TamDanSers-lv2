class PermissionModel {
  final dynamic id;
  final String type;
  final String fromDate;
  final String toDate;
  final String reason;
  final String status;
  final String? createdAt;

  PermissionModel({
    required this.id,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'],
      type: (json['type'] ?? '').toString(),
      fromDate:
          (json['start_date'] ?? json['from_date'] ?? json['fromDate'] ?? '')
              .toString(),
      toDate: (json['end_date'] ?? json['to_date'] ?? json['toDate'] ?? '')
          .toString(),
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['createdAt'])?.toString(),
    );
  }
}
