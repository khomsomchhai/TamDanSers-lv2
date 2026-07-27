class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      message: json["message"] ?? "",
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}