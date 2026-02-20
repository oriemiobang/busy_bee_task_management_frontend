import 'package:flutter/foundation.dart';
import 'package:frontend/features/dashboard/data/tasks_repository.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
import 'package:frontend/features/dashboard/model/task_stats.dart';

class TasksProvider extends ChangeNotifier {
  final TasksRepository _tasksRepository;

  TasksProvider(this._tasksRepository);

  // State
  List<TaskModel> _tasks = [];
  // TaskStats? _stats;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  bool _hasInitialLoad = false;
  bool _isLoadingFromCache = false;
  int _currentIndex = 0;

  // Getters
  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  // TaskStats? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasInitialLoad => _hasInitialLoad;
  bool get isLoadingFromCache => _isLoadingFromCache;
  int get currentIndex => _currentIndex;

  // Computed
  List<TaskModel> get todaysTasks => _tasks
      .where((task) =>
          task.deadline != null &&
          task.deadline!.day == DateTime.now().day &&
          task.deadline!.month == DateTime.now().month &&
          task.deadline!.year == DateTime.now().year)
      .toList();

  // ───────────────────────── Helpers ─────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setCurrentIndex(int val){
    _currentIndex = val;
    notifyListeners();
  }

  void _setLoadingFromCache(bool value) {
    _isLoadingFromCache = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ───────────────────────── Fetch Tasks ─────────────────────────

  Future<void> fetchTasks({bool refresh = false}) async {
    try {
      if (!_hasInitialLoad) refresh = true;

      if (refresh) {
        _tasks = [];
      }

      _setLoading(true);
      _setError(null);

      final newTasks = await _tasksRepository.getTasks();

      _tasks = refresh ? newTasks : [..._tasks, ...newTasks];

      _hasInitialLoad = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> loadTasksWithCacheFirst() async {
    _setLoadingFromCache(true);
    await fetchTasks(refresh: true);
    _setLoadingFromCache(false);
  }

  Future<void> ensureTasksLoaded() async {
    if (!_hasInitialLoad && !_isLoading) {
      await loadTasksWithCacheFirst();
    }
  }

  // ───────────────────────── Task Status ─────────────────────────

  Future<void> toggleTaskStatus(int taskId) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index == -1) return;

      final task = _tasks[index];
      final newStatus = task.isCompleted ? 'PROGRESS' : 'COMPLETED';

      final updatedTask = await _tasksRepository.updateTaskStatus(
        taskId: taskId,
        status: newStatus,
      );

      _tasks[index] = updatedTask;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }


Future<void> deleteTask(int taskId) async {
  try {
    // Optimistically remove task from UI first
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();

    // Delete task from backend
    await _tasksRepository.deleteTask(taskId);

    // Optionally, refresh stats
    // await fetchTaskStats();
  } catch (e) {
    _setError(e.toString());
    rethrow;
  }
}


  // ───────────────────────── SubTask Status (FIXED) ─────────────────────────

Future<void> toggleSubTaskStatus({
  required int taskId,
  required int subTaskId,
}) async {
  try {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];

    final subTaskIndex = task.subTasks.indexWhere((s) => s.id == subTaskId);
    if (subTaskIndex == -1) return;

    final subTask = task.subTasks[subTaskIndex];

    // Toggle locally
    final newStatus = !subTask.isDone;
    final updatedSubTask = subTask.copyWith(
      isDone: newStatus,
    );

    final updatedSubTasks = List<SubTaskModel>.from(task.subTasks);
    updatedSubTasks[subTaskIndex] = updatedSubTask;

    // Replace task
    final updatedTask = task.copyWith(
      subTasks: updatedSubTasks,
    );

    _tasks[taskIndex] = updatedTask;


    // Update UI immediately
    notifyListeners();

    // Send update to backend
    await _tasksRepository.updateSubTask(
      taskId: taskId,
      subTaskId: subTaskId,
      isDone: newStatus,
    );
  } catch (e) {
    _setError(e.toString());
    rethrow;
  }
}


// ADD THESE IMPORTS AT TOP


// REPLACE createTask method with resilient version
Future<TaskModel> createTask({
  required String title,
  required String description,
  required DateTime startTime,
  DateTime? deadline,
  List<SubTaskModel> subTasks = const [],
  String status = 'PROGRESS',
  String? recurrenceType,
  int? recurrenceInterval,
  List<String>? recurrenceDays,
  int? recurrenceDayOfMonth,
  DateTime? recurrenceEndDate,
}) async {
  _setLoading(true);
  _setError(null);

  try {
    // ✅ 1. Create task via repository
    final task = await _tasksRepository.createTask(
      title: title,
      description: description,
      startTime: startTime,
      deadline: deadline,
      subTasks: subTasks,
      status: status,
      recurrenceType: recurrenceType,
      recurrenceInterval: recurrenceInterval,
      recurrenceDays: recurrenceDays,
      recurrenceDayOfMonth: recurrenceDayOfMonth,
      recurrenceEndDate: recurrenceEndDate,
    );

    // ✅ 2. Optimistically add to local state (before parsing validation)
    _tasks.add(task);
    _setLoading(false);
    
    // ✅ 3. Show success AFTER task is in state (even if parsing has minor issues)
    // This ensures UI updates immediately while we handle edge cases gracefully
    notifyListeners();
    
    return task;
  } catch (e) {
    _setError('Failed to create task: ${e.toString()}');
    _setLoading(false);
    
    // ✅ 4. Still notify listeners so UI can show error state
    notifyListeners();
    rethrow;
  }
}
// REPLACE updateTask method (fully updated with recurrence)
Future<TaskModel> updateTask({
  required int taskId,
  String? title,
  String? description,
  DateTime? startTime,
  DateTime? deadline,
  List<SubTaskModel>? subTasks,
  String? status,
  // ✅ RECURRENCE PARAMETERS
  String? recurrenceType,
  int? recurrenceInterval,
  List<String>? recurrenceDays,
  int? recurrenceDayOfMonth,
  DateTime? recurrenceEndDate,
}) async {
  try {
    _setLoading(true);
    _setError(null);
    
    final updatedTask = await _tasksRepository.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      startTime: startTime,
      deadline: deadline,
      subTasks: subTasks,
      status: status,
      // ✅ PASS RECURRENCE DATA TO REPOSITORY
      recurrenceType: recurrenceType,
      recurrenceInterval: recurrenceInterval,
      recurrenceDays: recurrenceDays,
      recurrenceDayOfMonth: recurrenceDayOfMonth,
      recurrenceEndDate: recurrenceEndDate,
    );
    
    // Update local state
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
    
    _setLoading(false);
    notifyListeners();
    
    return updatedTask;
  } catch (e) {
    _setError('Failed to update task: ${e.toString()}');
    _setLoading(false);
    rethrow;
  }
}

// // REPLACE updateTask method
// Future<TaskModel> updateTask({
//   required int taskId,
//   String? title,
//   String? description,
//   DateTime? startTime,
//   DateTime? deadline,
//   List<SubTaskModel>? subTasks,
//   String? status,
// }) async {
//   try {
//     _setLoading(true);
//     _setError(null);
    
//     final updatedTask = await _tasksRepository.updateTask(
//       taskId: taskId,
//       title: title,
//       description: description,
//       startTime: startTime,
//       deadline: deadline,
//       subTasks: subTasks,
//       status: status,
//     );
    
//     // Update local state
//     final index = _tasks.indexWhere((t) => t.id == taskId);
//     if (index != -1) {
//       _tasks[index] = updatedTask;
//     }
    
//     _setLoading(false);
//     notifyListeners();
    
//     return updatedTask;
//   } catch (e) {
//     _setError(e.toString());
//     _setLoading(false);
//     rethrow;
//   }
// }



  // ─────── ───────────────── Stats ─────────────────────────

  // Future<void> fetchTaskStats() async {
  //   try {
  //     _stats = await _tasksRepository.getTaskStats();
  //     notifyListeners();
  //   } catch (_) {}
  // }

  // ───────────────────────── Utilities ─────────────────────────

  // TaskModel? getTaskById(int id) {
  //   try {
  //     return _tasks.firstWhere((t) => t.id == id);
  //   } catch (_) {
  //     return null;
  //   }
  // }

  void clearError() => _setError(null);

  void clearTasks() {
    _tasks = [];
    _hasInitialLoad = false;
    notifyListeners();
  }
}
