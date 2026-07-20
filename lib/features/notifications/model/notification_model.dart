class NotificationModel {
  final int id;
  final String title;
  final String description;
  final bool isRead;
  final String? type;
  final int? taskId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isRead,
    this.type,
    this.taskId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String?,
      taskId: json['taskId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      description: description,
      isRead: isRead ?? this.isRead,
      type: type,
      taskId: taskId,
      createdAt: createdAt,
    );
  }
}
