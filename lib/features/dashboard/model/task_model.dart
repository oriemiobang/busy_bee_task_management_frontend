class TaskModel {
  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? deadline;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userId;
  final List<SubTaskModel> subTasks;
  final TaskUser? user;
  
  // ✅ RECURRENCE FIELDS (matching Prisma schema)
  final String? recurrenceType;        // 'ONCE', 'DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'
  final int? recurrenceInterval;       // Every X days/weeks/months
  final List<String>? recurrenceDays;  // ['MON', 'WED', 'FRI'] for weekly
  final int? recurrenceDayOfMonth;     // 1-31 for monthly
  final DateTime? recurrenceEndDate;   // Optional end date

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    this.deadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.subTasks,
    this.user,
    // ✅ RECURRENCE PARAMETERS
    this.recurrenceType,
    this.recurrenceInterval,
    this.recurrenceDays,
    this.recurrenceDayOfMonth,
    this.recurrenceEndDate,
  });



  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;
    
    try {
      return value.map((e) => e.toString()).toList();
    } catch (e) {
      return null;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled Task',
      description: json['description'] ?? '',
      startTime: _parseDateTime(json['start_time']) ?? DateTime.now(),
      deadline: _parseDateTime(json['deadline']),
      status: json['status'] ?? 'UPCOMING',
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      userId: json['userId'] ?? json['user_id'] ?? 0,
      
      // ✅ CRITICAL FIX: Safe subtask parsing (handles empty arrays)
      subTasks: (json['subTasks'] as List? ?? json['subTask'] as List? ?? [])
          .where((e) => e != null)
          .map((e) => SubTaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      
      user: json['user'] != null
          ? TaskUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      
      // ✅ CRITICAL FIX: Safe recurrenceDays parsing
      recurrenceType: json['recurrenceType'] ?? json['recurrence_type'],
      recurrenceInterval: json['recurrenceInterval'] ?? json['recurrence_interval'],
      recurrenceDays: _parseStringList(json['recurrenceDays'] ?? json['recurrence_days']),
      recurrenceDayOfMonth: json['recurrenceDayOfMonth'] ?? json['recurrence_day_of_month'],
      recurrenceEndDate: _parseDateTime(json['recurrenceEndDate'] ?? json['recurrence_end_date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'start_time': startTime.toIso8601String(),
        if (deadline != null) 'deadline': deadline!.toIso8601String(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'userId': userId,
        'subTask': subTasks.map((s) => s.toJson()).toList(),
        if (user != null) 'user': user!.toJson(),
        
        // ✅ INCLUDE RECURRENCE FIELDS IF SET
        if (recurrenceType != null) 'recurrenceType': recurrenceType,
        if (recurrenceInterval != null) 'recurrenceInterval': recurrenceInterval,
        if (recurrenceDays != null && recurrenceDays!.isNotEmpty) 
          'recurrenceDays': recurrenceDays,
        if (recurrenceDayOfMonth != null) 'recurrenceDayOfMonth': recurrenceDayOfMonth,
        if (recurrenceEndDate != null) 
          'recurrenceEndDate': recurrenceEndDate!.toIso8601String(),
      };

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? deadline,
    String? status,
    List<SubTaskModel>? subTasks,
    // ✅ RECURRENCE PARAMETERS
    String? recurrenceType,
    int? recurrenceInterval,
    List<String>? recurrenceDays,
    int? recurrenceDayOfMonth,
    DateTime? recurrenceEndDate,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      userId: userId,
      subTasks: subTasks ?? this.subTasks,
      user: user,
      
      // ✅ PRESERVE RECURRENCE FIELDS
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      recurrenceDayOfMonth: recurrenceDayOfMonth ?? this.recurrenceDayOfMonth,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
    );
  }

  // Helpers
  bool get isCompleted => status == 'COMPLETED';
  int get completedSubTasksCount => subTasks.where((s) => s.isDone).length;
  bool get areAllSubTasksDone => subTasks.isNotEmpty && subTasks.every((s) => s.isDone);
  double get completionPercentage => subTasks.isEmpty ? 0 : completedSubTasksCount / subTasks.length * 100;

  // ✅ RECURRENCE HELPER: Human-readable description
  String get recurrenceDescription {
    if (recurrenceType == null || recurrenceType == 'ONCE') return 'Does not repeat';
    
    switch (recurrenceType) {
      case 'DAILY':
        return 'Every ${recurrenceInterval ?? 1} day${(recurrenceInterval ?? 1) > 1 ? 's' : ''}';
      case 'WEEKLY':
        if (recurrenceDays == null || recurrenceDays!.isEmpty) return 'Every week';
        final days = recurrenceDays!.map((d) => d.substring(0, 1)).join(', ');
        return 'Every ${recurrenceInterval ?? 1} week${(recurrenceInterval ?? 1) > 1 ? 's' : ''} on $days';
      case 'MONTHLY':
        return 'Day ${recurrenceDayOfMonth ?? 1} of every month';
      case 'YEARLY':
        return 'Every year';
      default:
        return 'Custom recurrence';
    }
  }


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
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled Subtask',
      isDone: json['isDone'] ?? json['is_done'] ?? false,
      taskId: json['taskId'] ?? json['task_id'] ?? 0,
      createdAt: TaskModel._parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: TaskModel._parseDateTime(json['updatedAt']),
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
