// lib/features/calendar/ui/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/calender/state/calender_provier.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
// import 'package:frontend/features/calendar/state/calendar_provider.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  String _formatTimeRange(DateTime start, DateTime? end) {
    final isSameDay = end != null &&
        start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    
    if (isSameDay) {
      return '${_formatTime(start)} - ${_formatTime(end!)}';
    } else if (end != null) {
      return '${_formatDate(start)} ${_formatTime(start)} - ${_formatDate(end)} ${_formatTime(end)}';
    } else {
      return '${_formatDate(start)} ${_formatTime(start)}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? Colors.blue.withOpacity(0.1)
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Task status toggle
          GestureDetector(
            onTap: () => context.read<CalendarProvider>().toggleTaskStatus(task.id),
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: task.isCompleted ? const Color(0xFF6366F1) : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted ? const Color(0xFF6366F1) : Colors.grey,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          
          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task title with completion styling
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: task.isCompleted ? Colors.grey : Colors.white,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Time range
                Text(
                  _formatTimeRange(task.startTime, task.deadline),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                
                // Subtask progress
                if (task.subTasks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: task.completionPercentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${task.completedSubTasksCount}/${task.subTasks.length}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Delete action
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Task', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this task?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Navigator.pop(context);
              // context.read<CalendarProvider>().deleteTask(task.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}