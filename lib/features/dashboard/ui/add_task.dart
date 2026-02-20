// lib/features/dashboard/ui/screens/new_task_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';
import 'package:frontend/features/dashboard/ui/widgets/date_picker.dart';
import 'package:frontend/features/dashboard/ui/widgets/recurrence_picker.dart';
import 'package:frontend/features/dashboard/ui/widgets/subtask_list.dart';
import 'package:frontend/features/dashboard/ui/widgets/task_title_field.dart';
import 'package:frontend/features/dashboard/ui/widgets/time_picker.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
import 'package:frontend/core/extensions/date_extensions.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NewTaskScreen extends StatefulWidget {
  final int? taskId;
  final TaskModel? existingTask;

  const NewTaskScreen({
    super.key,
    this.taskId,
    this.existingTask,
  });

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime? _deadline;
  bool _isDeadlineEnabled = false;
  List<SubTaskModel> _subTasks = [];

  // RECURRENCE STATE
  String _recurrenceType = 'ONCE';
  int _recurrenceInterval = 1;
  List<String> _recurrenceDays = [];
  int _recurrenceDayOfMonth = 1;

  bool _isCreating = true;
  bool _isSaving = false;
@override
void initState() {
  super.initState();
  _isCreating = widget.taskId == null;

  if (widget.existingTask != null) {
    final task = widget.existingTask!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _startTime = task.startTime;
    _deadline = task.deadline;
    _isDeadlineEnabled = task.deadline != null;
    _subTasks = List.from(task.subtasks);

    // LOAD EXISTING RECURRENCE DATA
    _recurrenceType = task.recurrenceType ?? 'ONCE';
    _recurrenceInterval = task.recurrenceInterval ?? 1;
    _recurrenceDays = task.recurrenceDays ?? [];
    _recurrenceDayOfMonth = task.recurrenceDayOfMonth ?? 1;
  } else {
    _deadline = DateTime.now().add(const Duration(days: 1));
    _isDeadlineEnabled = true;
    //DEFAULT TO NON-RECURRING FOR NEW TASKS
    _recurrenceType = 'ONCE';
    _recurrenceInterval = 1;
    _recurrenceDays = [];
    _recurrenceDayOfMonth = 1;
  }
}

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

Future<void> _saveTask() async {
  if (_isSaving) return;

  final title = _titleController.text.trim();
  if (title.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task title cannot be empty'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _isSaving = true);

  try {
    final provider = context.read<TasksProvider>();

    if (_isCreating) {
      // INCLUDE RECURRENCE DATA IN CREATE
      await provider.createTask(
        title: title,
        description: _descriptionController.text.trim(),
        startTime: _startTime,
        deadline: _isDeadlineEnabled ? _deadline : null,
        subtasks: _subTasks,
        status: 'PROGRESS', 
        
        // RECURRENCE PARAMETERS
        recurrenceType: _recurrenceType,
        recurrenceInterval: _recurrenceType != 'ONCE' ? _recurrenceInterval : null,
        recurrenceDays: _recurrenceType == 'WEEKLY' && _recurrenceDays.isNotEmpty 
            ? _recurrenceDays 
            : null,
        recurrenceDayOfMonth: _recurrenceType == 'MONTHLY' 
            ? _recurrenceDayOfMonth 
            : null,
        recurrenceEndDate: null,
      );
    } else {
      // INCLUDE RECURRENCE DATA IN UPDATE
      await provider.updateTask(
        taskId: widget.taskId!,
        title: title,
        description: _descriptionController.text.trim(),
        startTime: _startTime,
        deadline: _isDeadlineEnabled ? _deadline : null,
        subtasks: _subTasks.isNotEmpty ? _subTasks : null,
        status: 'PROGRESS',
        
        // RECURRENCE PARAMETERS
        recurrenceType: _recurrenceType,
        recurrenceInterval: _recurrenceType != 'ONCE' ? _recurrenceInterval : null,
        recurrenceDays: _recurrenceType == 'WEEKLY' && _recurrenceDays.isNotEmpty 
            ? _recurrenceDays 
            : null,
        recurrenceDayOfMonth: _recurrenceType == 'MONTHLY' 
            ? _recurrenceDayOfMonth 
            : null,
        recurrenceEndDate: null,
      );
    }

    if (context.mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isCreating ? 'Task created!' : 'Task updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save task: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (context.mounted) {
      setState(() => _isSaving = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isCreating ? 'New Task' : 'Edit Task',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _saveTask,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // TITLE FIELD
            TaskTitleField(
              controller: _titleController,
              autoFocus: true,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 24),

            // DATE/TIME SECTION
            sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TimePicker(
                    time: _startTime,
                    onTimeChanged: () => setState(() {}),
                    title: 'Start Time',
                    subtitle: 'Set a specific time',
                  ),
                  const SizedBox(height: 19),
                  const Divider(color: Colors.grey, height: 1),
                  const SizedBox(height: 19),
                  DatePicker(
                    date: _startTime,
                    onDateChanged: () => setState((){}),
                    title: 'Date',
                    subtitle: '',
                    isToday: _startTime.isSameDay(DateTime.now()),
                  ),
                  const SizedBox(height: 16),

                  // DEADLINE SECTION
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.backgroundDark,
                    ),
                    child: _buildDeadlineSection(),
                  ),

                  const SizedBox(height: 16),

                  // RECURRENCE SECTION (NEW)
                  const Divider(color: Colors.grey, height: 1),
                  const SizedBox(height: 16),
                  RecurrencePicker(
                    initialType: _recurrenceType,
                    initialInterval: _recurrenceInterval,
                    initialDays: _recurrenceDays,
                    onRecurrenceChanged: (data) {
                      setState(() {
                        _recurrenceType = data['type'] as String;
                        if (data.containsKey('interval')) {
                          _recurrenceInterval = data['interval'] as int;
                        }
                        if (data.containsKey('days')) {
                          _recurrenceDays = List<String>.from(data['days']);
                        }
                        if (data.containsKey('dayOfMonth')) {
                          _recurrenceDayOfMonth = data['dayOfMonth'] as int;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DESCRIPTION SECTION
            sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    minLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Add details or notes...',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[800]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SUBTASKS SECTION
            SubTasksList(
              subtasks: _subTasks,
              onSubTaskAdded: (subTask) {
                setState(() => _subTasks.add(subTask));
              },
              onSubTaskRemoved: (id) {
                setState(() => _subTasks.removeWhere((e) => e.id == id));
              },
              onSubTaskChanged: (id, updated) {
                final index = _subTasks.indexWhere((e) => e.id == id);
                if (index != -1) {
                  setState(() => _subTasks[index] = updated);
                }
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // SAVE BUTTON (FULL WIDTH)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// DEADLINE SECTION
  Widget _buildDeadlineSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(55, 244, 67, 54),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.hourglass_bottom,
                  color: Color.fromARGB(154, 244, 67, 54),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Deadline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Due date and time enabled',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              /// SWITCH
              Switch(
                value: _isDeadlineEnabled,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    _isDeadlineEnabled = value;
                    if (!value) _deadline = null;
                  });
                },
              ),
            ],
          ),
          if (_isDeadlineEnabled) ...[
            const SizedBox(height: 16),
            /// DATE + TIME
            Row(
              children: [
                /// DATE
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _deadline ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        builder: (context, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: ColorScheme.dark(primary: AppColors.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          final time = _deadline ?? DateTime.now();
                          _deadline = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                    child: _pickerBox(
                      title: 'DATE',
                      value: DateFormat('MMM d, yyyy').format(_deadline ?? DateTime.now()),
                      icon: Icons.calendar_month,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                /// TIME
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime.now()),
                        builder: (context, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: ColorScheme.dark(primary: AppColors.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          final date = _deadline ?? DateTime.now();
                          _deadline = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    },
                    child: _pickerBox(
                      title: 'TIME',
                      value: DateFormat('hh:mm a').format(_deadline ?? DateTime.now()),
                      icon: Icons.access_time,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// REUSABLE PICKER UI
  Widget _pickerBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  /// CARD CONTAINER
  Widget sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151A23),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}