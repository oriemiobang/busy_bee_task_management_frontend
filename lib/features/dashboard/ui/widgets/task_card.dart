// lib/features/dashboard/ui/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onEdit;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback onTaskToggle;
  final Function(int subTaskId) onSubTaskToggle;
  final bool isHome;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTaskToggle,
    required this.onSubTaskToggle,
  required this.isHome,
    this.onEdit,
    this.onUpdate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Main task checkbox with visual feedback
          GestureDetector(
            onTap: onTaskToggle,
            child: _buildCheckbox(isCompleted: task.isCompleted),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task header with title, time, and actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              color: task.isCompleted 
                                  ? Colors.grey[600] 
                                  : Colors.white,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (task.startTime != null && task.deadline != null) ...[
                            Row(
                              children: [
                           
                                const SizedBox(width: 5),
                                Text(
                                  _formatTimeRange(task.startTime!, task.deadline!),
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Subtask progress + menu actions
                    Row(
                      children: [
                        _buildSubtaskProgress(
                          completed: task.completedSubTasksCount,
                          total: task.subtasks.length,
                        ),
                        const SizedBox(width: 8),
                      isHome?   _buildActionMenu(context): SizedBox(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.grey, height: 16),
                // Subtasks list
                if (task.subtasks.isNotEmpty) ...[
                  Column(
                    children: task.subtasks.map((subTask) {
                      return GestureDetector(
                        onTap: () => onSubTaskToggle(subTask.id),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              _buildCheckbox(isCompleted: subTask.isDone),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  subTask.title,
                                  style: TextStyle(
                                    color: subTask.isDone
                                        ? Colors.grey[500]
                                        : AppColors.textSecondary,
                                    fontSize: 15.5,
                                    decoration: subTask.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'No subtasks yet',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Visual checkbox with checkmark icon when completed
  Widget _buildCheckbox({required bool isCompleted}) {
    return Container(
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted 
              ? AppColors.primary 
              : AppColors.borderDark,
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }

  // ✅ Subtask progress indicator
  Widget _buildSubtaskProgress({required int completed, required int total}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(96, 66, 66, 66),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$completed/$total',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }


  // ✅ Action menu with proper async handling
  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
      onSelected: (value) async {
        switch (value) {
          case 'update':
            onUpdate?.call();
            break;
          case 'delete':
            if (onDelete != null) {
              // Show confirmation dialog before delete
              await _showDeleteConfirmation(context);
            }
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        if (onEdit != null)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(children: [
              Icon(Icons.edit, size: 18, color: Colors.blue),
              SizedBox(width: 12),
              Text('Edit'),
            ]),
          ),
        if (onUpdate != null)
          const PopupMenuItem<String>(
            value: 'update',
            child: Row(children: [
              Icon(Icons.update, size: 18, color: Colors.orange),
              SizedBox(width: 12),
              Text('Update Status'),
            ]),
          ),
        if (onDelete != null)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ]),
          ),
      ],
    );
  }

  // ✅ Confirmation dialog before deletion
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted && onDelete != null) {
        onDelete!();
        
        // Show feedback snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted successfully'),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Implement undo functionality if needed
              },
            ),
          ),
        );
      }
    });
  }

  // ✅ Format time range properly (handles same-day vs multi-day)
  String _formatTimeRange(DateTime start, DateTime end) {
    final isSameDay = start.day == end.day && 
                      start.month == end.month && 
                      start.year == end.year;
    
    if (isSameDay) {
      return '${_formatTime(start)} - ${_formatTime(end)}';
    } else {
      return '${_formatDate(start)} ${_formatTime(start)} - ${_formatDate(end)} ${_formatTime(end)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}