// // lib/features/dashboard/model/task_stats.dart
// class TaskStats {
//   final int totalTasks;
//   final int completedTasks;
//   final int pendingTasks;
//   final int overdueTasks;

//   TaskStats({
//     required this.totalTasks,
//     required this.completedTasks,
//     required this.pendingTasks,
//     required this.overdueTasks,
//   });

//   factory TaskStats.fromJson(Map<String, dynamic> json) {
//     return TaskStats(
//       totalTasks: json['totalTasks'] ?? 0,
//       completedTasks: json['completedTasks'] ?? 0,
//       pendingTasks: json['pendingTasks'] ?? 0,
//       overdueTasks: json['overdueTasks'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'totalTasks': totalTasks,
//       'completedTasks': completedTasks,
//       'pendingTasks': pendingTasks,
//       'overdueTasks': overdueTasks,
//     };
//   }

//   double get completionRate {
//     if (totalTasks == 0) return 0.0;
//     return completedTasks / totalTasks * 100;
//   }
// }