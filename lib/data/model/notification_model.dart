class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String? dueDate;
  final String? subtitle;
  final String? type;
  final Map<String, dynamic>? rawJson;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.dueDate,
    this.subtitle,
    this.type,
    this.rawJson,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      final rawDate = json["created_at"] ?? json["createdAt"] ?? json["date"];
      parsedDate = rawDate != null ? DateTime.parse(rawDate.toString()) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      id: json["id"] is int ? json["id"] : (int.tryParse(json["id"]?.toString() ?? '') ?? 0),
      title: json["title"] ?? "",
      message: json["message"] ?? json["body"] ?? "",
      createdAt: parsedDate,
      dueDate: json["due_date"] ?? json["dueDate"],
      subtitle: json["subtitle"] ?? json["author"] ?? json["teacher_name"],
      type: json["type"] ?? json["notification_type"],
      rawJson: json,
    );
  }
}