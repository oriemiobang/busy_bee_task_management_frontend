class TaskModel {
  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? deadline;
  final int sortOrder;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userId;
  final List<SubTaskModel> subTasks;
  final TaskUser? user;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    this.deadline,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.subTasks,
    this.user,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      sortOrder: json['sort_order'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userId: json['userId'],
      subTasks: (json['subTask'] as List? ?? [])
          .map((e) => SubTaskModel.fromJson(e))
          .toList(),
      user: json['user'] != null
          ? TaskUser.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'start_time': startTime.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'sort_order': sortOrder,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'userId': userId,
        'subTask': subTasks.map((s) => s.toJson()).toList(),
        'user': user?.toJson(),
      };

  /// Needed for cache & optimistic updates
  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? deadline,
    int? sortOrder,
    String? status,
    List<SubTaskModel>? subTasks,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      deadline: deadline ?? this.deadline,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      userId: userId,
      subTasks: subTasks ?? this.subTasks,
      user: user,
    );
  }

  /// 🔹 Helpers
  bool get isCompleted => status == 'COMPLETED';

  int get completedSubTasksCount =>
      subTasks.where((s) => s.isDone).length;

  bool get areAllSubTasksDone =>
      subTasks.isNotEmpty && subTasks.every((s) => s.isDone);

  double get completionPercentage =>
      subTasks.isEmpty
          ? 0
          : completedSubTasksCount / subTasks.length * 100;
}
class SubTaskModel {
  final int id;
  final String title;
  final bool isDone;
  final int taskId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SubTaskModel({
    required this.id,
    required this.title,
    required this.isDone,
    required this.taskId,
    required this.createdAt,
    this.updatedAt,
  });

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'] ?? false,
      taskId: json['taskId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'taskId': taskId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  /// 🔁 Critical for cache updates
  SubTaskModel copyWith({
    String? title,
    bool? isDone,
    DateTime? updatedAt,
  }) {
    return SubTaskModel(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      taskId: taskId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
class TaskUser {
  final int id;
  final String name;
  final String email;

  TaskUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory TaskUser.fromJson(Map<String, dynamic> json) {
    return TaskUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
