// lib/features/calendar/state/calendar_provider.dart
import 'package:flutter/foundation.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';

class CalendarProvider with ChangeNotifier {
  final TasksProvider _tasksProvider;
  
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();

  List<TaskModel> _occurrences = [];
  bool _isLoadingOccurrences = false;

  CalendarProvider(this._tasksProvider) {
    //  Listen to task changes for real-time updates
    _tasksProvider.addListener(_fetchOccurrences);
    //  Initialize with today's date
    _selectedDate = DateTime.now();
    _currentDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _fetchOccurrences();
  }

  Future<void> _fetchOccurrences() async {
    _isLoadingOccurrences = true;
    notifyListeners();

    try {
      final start = DateTime(_currentDate.year, _currentDate.month, 1);
      final end = DateTime(_currentDate.year, _currentDate.month + 1, 0, 23, 59, 59);

      _occurrences = await _tasksProvider.getOccurrences(start, end);
    } catch (e) {
      print('Failed to fetch occurrences: $e');
      _occurrences = [];
    } finally {
      _isLoadingOccurrences = false;
      notifyListeners();
    }
  }

  //  Get ALL tasks directly from TasksProvider (single source of truth) + occurrences
  List<TaskModel> get allTasks {
    final normalTasks = _tasksProvider.tasks.where(
        (t) => t.recurrenceType == null || t.recurrenceType == 'ONCE');
    return [...normalTasks, ..._occurrences];
  }

  //  Get tasks for SELECTED date (reactive)
  List<TaskModel> get tasksForSelectedDate => allTasks.where((task) {
        final date = _selectedDate;
        final matchesStart = task.startTime.year == date.year &&
            task.startTime.month == date.month &&
            task.startTime.day == date.day;
        final matchesDeadline = task.deadline != null &&
            task.deadline!.year == date.year &&
            task.deadline!.month == date.month &&
            task.deadline!.day == date.day;
        return matchesStart || matchesDeadline;
      }).toList();

  //  Get task count for ANY date (for dot indicators)
  int getTaskCountForDate(DateTime date) {
    return allTasks.where((task) {
        final matchesStart = task.startTime.year == date.year &&
            task.startTime.month == date.month &&
            task.startTime.day == date.day;
        final matchesDeadline = task.deadline != null &&
            task.deadline!.year == date.year &&
            task.deadline!.month == date.month &&
            task.deadline!.day == date.day;
        return matchesStart || matchesDeadline;
    }).length;
  }

  // State getters
  DateTime get selectedDate => _selectedDate;
  DateTime get currentDate => _currentDate;
  bool get isLoading => _isLoadingOccurrences || _tasksProvider.isLoading;
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
    _fetchOccurrences();
  }

  void goToNextMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    _fetchOccurrences();
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
    _tasksProvider.removeListener(_fetchOccurrences);
    super.dispose();
  }
}