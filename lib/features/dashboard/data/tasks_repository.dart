// lib/features/dashboard/data/tasks_repository.dart
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/dashboard/data/tasks_api.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
import 'package:frontend/features/dashboard/model/task_stats.dart';

class TasksRepository {
  final TasksApi _tasksApi;
  final SecureStorage _secureStorage;

  TasksRepository(this._tasksApi, this._secureStorage);

  // ===================== TASK FETCH =====================
  Future<List<TaskModel>> getTasks({String? status, DateTime? date}) async {
    try {
      final cacheKey = _generateCacheKey(status: status, date: date);

      final isCacheValid = await _secureStorage.isCacheValid(key: cacheKey);
      if (isCacheValid) {
        print('Loading tasks from cache for key: $cacheKey');
        final cachedTasks = await _getCachedTasks(cacheKey);
        if (cachedTasks.isNotEmpty) {
          print('Loaded ${cachedTasks.length} tasks from cache');
          return cachedTasks;
        }
      }

      print('Fetching tasks from API...');
      final tasks = await _tasksApi.getTasks(status: status, date: date);

      print('Received ${tasks.length} tasks from API');
      await _cacheTasks(tasks, cacheKey);
      // Also cache each task individually
      for (var task in tasks) {
        await _cacheTaskById(task);
      }

      return tasks;
    } catch (e) {
      print('Error in getTasks: $e');
      try {
        final cacheKey = _generateCacheKey(status: status, date: date);
        final cachedTasks = await _getCachedTasks(cacheKey);
        if (cachedTasks.isNotEmpty) {
          print('Falling back to cached data (${cachedTasks.length} tasks)');
          return cachedTasks;
        }
      } catch (_) {}
      return [];
    }
  }

  // ===================== TASK CREATE =====================
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime startTime,
    DateTime? deadline,
    List<SubTaskModel> subtasks = const [],
    String status = 'PROGRESS',
    String? recurrenceType,
    int? recurrenceInterval,
    List<String>? recurrenceDays,
    int? recurrenceDayOfMonth,
    DateTime? recurrenceEndDate,
  }) async {
    try {
      final task = await _tasksApi.createTask(
        title: title,
        description: description,
        startTime: startTime,
        deadline: deadline,
        subtasks: subtasks,
        status: status,
        recurrenceType: recurrenceType,
        recurrenceInterval: recurrenceInterval,
        recurrenceDays: recurrenceDays,
        recurrenceDayOfMonth: recurrenceDayOfMonth,
        recurrenceEndDate: recurrenceEndDate,
      );

      await _addTaskToCache(task);
      await _cacheTaskById(task);
      return task;
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  // ===================== TASK UPDATE =====================
  Future<TaskModel> updateTask({
    required int taskId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? deadline,
    List<SubTaskModel>? subtasks,
    String? status,
    String? recurrenceType,
    int? recurrenceInterval,
    List<String>? recurrenceDays,
    int? recurrenceDayOfMonth,
    DateTime? recurrenceEndDate,
  }) async {
    try {
      final task = await _tasksApi.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        startTime: startTime,
        deadline: deadline,
        subtasks: subtasks,
        status: status,
        recurrenceType: recurrenceType,
        recurrenceInterval: recurrenceInterval,
        recurrenceDays: recurrenceDays,
        recurrenceDayOfMonth: recurrenceDayOfMonth,
        recurrenceEndDate: recurrenceEndDate,
      );

      await _updateTaskInCache(task);
      await _cacheTaskById(task);
      return task;
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<TaskModel> updateTaskStatus({required int taskId, required String status}) async {
    try {
      final task = await _tasksApi.updateTaskStatus(taskId: taskId, status: status);
      await _updateTaskInCache(task);
      await _cacheTaskById(task);
      return task;
    } catch (e) {
      print('Error updating task status: $e');
      rethrow;
    }
  }

  // ===================== SUBTASK UPDATE =====================
  Future<TaskModel> updateSubTask({
    required int taskId,
    required int subTaskId,
    String? title,
    bool? isDone,
  }) async {
    try {
      final updatedTask = await _tasksApi.updateSubTask(
        taskId: taskId,
        subTaskId: subTaskId,
        title: title,
        isDone: isDone,
      );

      await _updateTaskInCache(updatedTask);
      await _cacheTaskById(updatedTask);
      return updatedTask;
    } catch (e) {
      print('Error updating subtask: $e');
      try {
        final cachedTask = await _getCachedTaskById(taskId);
        if (cachedTask != null) {
          final subTaskIndex = cachedTask.subtasks.indexWhere((s) => s.id == subTaskId);
          if (subTaskIndex != -1) {
            final oldSubTask = cachedTask.subtasks[subTaskIndex];
            cachedTask.subtasks[subTaskIndex] = oldSubTask.copyWith(
              title: title ?? oldSubTask.title,
              isDone: isDone ?? oldSubTask.isDone,
              updatedAt: DateTime.now(),
            );
            await _updateTaskInCache(cachedTask);
            await _cacheTaskById(cachedTask);
            return cachedTask;
          }
        }
      } catch (_) {}
      rethrow;
    }
  }

  Future<SubTaskModel> updateSubTaskStatus({
    required int taskId,
    required int subTaskId,
    required bool isDone,
  }) async {
    try {
      final subTask = await _tasksApi.updateSubTaskStatus(
        taskId: taskId,
        subTaskId: subTaskId,
        isDone: isDone,
      );
      await _updateSubTaskInCache(taskId, subTaskId, isDone: isDone);
      return subTask;
    } catch (e) {
      print('Error updating subtask status: $e');
      rethrow;
    }
  }

  // ===================== TASK DELETE =====================
  Future<void> deleteTask(int taskId) async {
    try {
      await _tasksApi.deleteTask(taskId);
      await _removeTaskFromCache(taskId);
      // await _secureStorage.clearCacheByKey('task_$taskId');
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // ===================== CACHE HELPERS =====================
  String _generateCacheKey({String? status, DateTime? date}) {
    final parts = ['all_tasks'];
    if (status != null) parts.add('status_${status.toLowerCase()}');
    if (date != null) parts.add('date_${date.toIso8601String().split('T')[0]}');
    return parts.join('_');
  }

  Future<void> _cacheTasks(List<TaskModel> tasks, String cacheKey) async {
    try {
      final tasksJson = tasks.map((t) => t.toJson()).toList();
      await _secureStorage.cacheData(key: cacheKey, data: tasksJson, dataType: 'tasks');
      print('Cached ${tasks.length} tasks with key: $cacheKey');
    } catch (e) {
      print('Error caching tasks: $e');
    }
  }

  Future<void> _cacheTaskById(TaskModel task) async {
    try {
      await _secureStorage.cacheData(key: 'task_${task.id}', data: task.toJson(), dataType: 'tasks');
      print('Cached individual task ${task.id}');
    } catch (e) {
      print('Error caching individual task: $e');
    }
  }

  Future<List<TaskModel>> _getCachedTasks(String cacheKey) async {
    try {
      final cachedData = await _secureStorage.getCachedData(key: cacheKey, dataType: 'tasks');
      if (cachedData == null || cachedData.isEmpty) return [];
      return (cachedData as List<dynamic>).map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      print('Error reading cached tasks: $e');
      return [];
    }
  }

  Future<TaskModel?> _getCachedTaskById(int taskId) async {
    try {
      final cachedData = await _secureStorage.getCachedData(key: 'task_$taskId', dataType: 'tasks');
      if (cachedData != null) return TaskModel.fromJson(cachedData);
      final allTasks = await _getCachedTasks(_generateCacheKey());
      final foundTask = allTasks.firstWhere((t) => t.id == taskId, orElse: () => null as TaskModel);
      return foundTask;
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateTaskInCache(TaskModel task) async {
    try {
      final allTasksKey = _generateCacheKey();
      final cachedTasks = await _getCachedTasks(allTasksKey);
      final idx = cachedTasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        cachedTasks[idx] = task;
        await _cacheTasks(cachedTasks, allTasksKey);
        print('Updated task ${task.id} in all_tasks cache');
      }
    } catch (e) {
      print('Error updating task in cache: $e');
    }
  }

  Future<void> _addTaskToCache(TaskModel task) async {
    try {
      final allTasksKey = _generateCacheKey();
      final cachedTasks = await _getCachedTasks(allTasksKey);
      cachedTasks.add(task);
      await _cacheTasks(cachedTasks, allTasksKey);
      print('Added task ${task.id} to cache');
    } catch (e) {
      print('Error adding task to cache: $e');
    }
  }

  Future<void> _removeTaskFromCache(int taskId) async {
    try {
      final allTasksKey = _generateCacheKey();
      final cachedTasks = await _getCachedTasks(allTasksKey);
      final updatedTasks = cachedTasks.where((t) => t.id != taskId).toList();
      await _cacheTasks(updatedTasks, allTasksKey);
      print('Removed task $taskId from cache');
    } catch (e) {
      print('Error removing task from cache: $e');
    }
  }

  Future<void> _updateSubTaskInCache(int taskId, int subTaskId, {bool? isDone, String? title}) async {
    final task = await _getCachedTaskById(taskId);
    if (task != null) {
      final idx = task.subtasks.indexWhere((s) => s.id == subTaskId);
      if (idx != -1) {
        task.subtasks[idx] = task.subtasks[idx].copyWith(
          isDone: isDone ?? task.subtasks[idx].isDone,
          title: title ?? task.subtasks[idx].title,
          updatedAt: DateTime.now(),
        );
        await _updateTaskInCache(task);
        await _cacheTaskById(task);
        print('Updated subtask $subTaskId in cache');
      }
    }
  }

  // ===================== CLEAR CACHE =====================
  Future<void> clearTaskCache() async {
    try {
      await _secureStorage.clearCacheByDataType('tasks');
      await _secureStorage.clearCacheByDataType('stats');
      print('Cleared all task cache');
    } catch (e) {
      print('Error clearing task cache: $e');
    }
  }
}