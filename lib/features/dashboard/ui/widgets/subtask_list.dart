import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';

class SubTasksList extends StatefulWidget {
  final List<SubTaskModel> subTasks;
  final Function(int, SubTaskModel) onSubTaskChanged;
  final Function(SubTaskModel) onSubTaskAdded;
  final Function(int) onSubTaskRemoved;

  const SubTasksList({
    super.key,
    required this.subTasks,
    required this.onSubTaskChanged,
    required this.onSubTaskAdded,
    required this.onSubTaskRemoved,
  });

  @override
  State<SubTasksList> createState() => _SubTasksListState();
}

class _SubTasksListState extends State<SubTasksList> {
  final _newSubTaskController = TextEditingController();

  @override
  void dispose() {
    _newSubTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tasks header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SUB-TASKS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            TextButton(
              onPressed: () {
                if (_newSubTaskController.text.isNotEmpty) {
                  widget.onSubTaskAdded(
                    SubTaskModel(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: _newSubTaskController.text,
                      isDone: false,
                      taskId: 0, // Will be updated later
                      createdAt: DateTime.now(),
                    ),
                  );
                  _newSubTaskController.clear();
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Sub-tasks list
        if (widget.subTasks.isEmpty)
          const Text(
            'No sub-tasks yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ...widget.subTasks.map((subTask) => _buildSubTaskItem(subTask)),
        
        // Add new sub-task field
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: _newSubTaskController,
            decoration: InputDecoration(
              hintText: 'Add sub-task...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                widget.onSubTaskAdded(
                  SubTaskModel(
                    id: DateTime.now().millisecondsSinceEpoch,
                    title: value,
                    isDone: false,
                    taskId: 0,
                    createdAt: DateTime.now(),
                  ),
                );
                _newSubTaskController.clear();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubTaskItem(SubTaskModel subTask) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.surfaceDark
      ),
      child: Row(
        children: [
          Checkbox(
            value: subTask.isDone,
            onChanged: (value) {
              widget.onSubTaskChanged(
                subTask.id,
                subTask.copyWith(isDone: value ?? false),
              );
            },
            activeColor: Colors.blue,
          ),
          Expanded(
            child: Text(
              subTask.title,
              style: TextStyle(
                decoration: subTask.isDone ? TextDecoration.lineThrough : null,
                color: subTask.isDone ? Colors.grey[500] : Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 16),
            onPressed: () => widget.onSubTaskRemoved(subTask.id),
          ),
        ],
      ),
    );
  }
}