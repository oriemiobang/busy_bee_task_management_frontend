// lib/features/calendar/state/calendar_provider.dart
import 'package:flutter/foundation.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';

class CalendarProvider with ChangeNotifier {
  final TasksProvider _tasksProvider;
  
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();

  CalendarProvider(this._tasksProvider) {
    //  Listen to task changes for real-time updates
    _tasksProvider.addListener(_onTasksUpdated);
    //  Initialize with today's date
    _selectedDate = DateTime.now();
    _currentDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  void _onTasksUpdated() => notifyListeners();

  //  Get ALL tasks directly from TasksProvider (single source of truth)
  List<TaskModel> get allTasks => _tasksProvider.tasks;

  //  Get tasks for SELECTED date (reactive)
  List<TaskModel> get tasksForSelectedDate => allTasks.where((task) =>
        task.createdAt.year == _selectedDate.year &&
        task.createdAt.month == _selectedDate.month &&
        task.createdAt.day == _selectedDate.day).toList();

  //  Get task count for ANY date (for dot indicators)
  int getTaskCountForDate(DateTime date) {
    return allTasks.where((task) =>
        task.createdAt.year == date.year &&
        task.createdAt.month == date.month &&
        task.createdAt.day == date.day).length;
  }

  // State getters
  DateTime get selectedDate => _selectedDate;
  DateTime get currentDate => _currentDate;
  bool get isLoading => _tasksProvider.isLoading;
  String? get error => _tasksProvider.error;

  //  CRITICAL: Select ANY date (handles cross-month navigation)
  void selectDate(DateTime date) {
    _selectedDate = date;
    // Auto-navigate calendar view to the selected date's month
    if (date.month != _currentDate.month || date.year != _currentDate.year) {
      _currentDate = DateTime(date.year, date.month, 1);
    }
    notifyListeners();
  }

  void goToPreviousMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    notifyListeners();
  }

  void goToToday() {
    final now = DateTime.now();
    _currentDate = DateTime(now.year, now.month, 1);
    _selectedDate = now;
    notifyListeners();
  }

  // Task actions (delegate to TasksProvider)
  Future<void> toggleTaskStatus(int taskId) async {
    await _tasksProvider.toggleTaskStatus(taskId);
  }

  Future<void> toggleSubTaskStatus(int taskId, int subTaskId) async {
    await _tasksProvider.toggleSubTaskStatus(
      taskId: taskId,
      subTaskId: subTaskId,
    );
  }

  Future<void> deleteTask(int taskId) async {
    await _tasksProvider.deleteTask(taskId);
  }

  @override
  void dispose() {
    _tasksProvider.removeListener(_onTasksUpdated);
    super.dispose();
  }
}