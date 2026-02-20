// lib/features/dashboard/data/tasks_repository.dart
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/dashboard/data/tasks_api.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
// import 'package:frontend/core/services/secure_storage.dart';
import 'dart:convert';

import 'package:frontend/features/dashboard/model/task_stats.dart';

class TasksRepository {
  final TasksApi _tasksApi;
  final SecureStorage _secureStorage;

  TasksRepository(this._tasksApi, this._secureStorage);

  Future<List<TaskModel>> getTasks({
    String? status,
    DateTime? date,
  }) async {
    try {
      // Generate cache key based on parameters
      final cacheKey = _generateCacheKey(status: status, date: date);
      
      // Check if we have valid cache for this query
      final isCacheValid = await _secureStorage.isCacheValid(key: cacheKey);
      if (isCacheValid) {
        print('Loading tasks from cache for key: $cacheKey');
        final cachedTasks = await _getCachedTasks(cacheKey);
        
        if (cachedTasks.isNotEmpty) {
          print('Loaded ${cachedTasks.length} tasks from cache');
          return cachedTasks;
        }
      }
      
      // If no valid cache, fetch from API
      print('Fetching tasks from API...');
      final tasks = await _tasksApi.getTasks(
        status: status,
        date: date,
      );
      
      print('Received ${tasks.length} tasks from API');
      
      // Cache the tasks
      await _cacheTasks(tasks, cacheKey);
      
      return tasks;
    } catch (e) {
      print('Error in getTasks: $e');
      
      // Try to return cached data as fallback
      try {
        final cacheKey = _generateCacheKey(status: status, date: date);
        final cachedTasks = await _getCachedTasks(cacheKey);
        if (cachedTasks.isNotEmpty) {
          print('Falling back to cached data (${cachedTasks.length} tasks)');
          return cachedTasks;
        }
      } catch (cacheError) {
        print('Could not load from cache: $cacheError');
      }
      
      return []; // Return empty list on error
    }
  }
Future<TaskModel> updateSubTask({
  required int taskId,
  required int subTaskId,
  String? title,
  bool? isDone,
}) async {
  try {
    //  Call API
    final updatedTask = await _tasksApi.updateSubTask(
      taskId: taskId,
      subTaskId: subTaskId,
      title: title,
      isDone: isDone,
    );


    await _updateTaskInCache(updatedTask);

    return updatedTask;
  } catch (e) {
    print('Error updating subtask: $e');

    // 3️ Fallback: try cache update if possible
    try {
      final cachedTask = await _getCachedTaskById(taskId);
      if (cachedTask != null) {
        final subTaskIndex =
            cachedTask.subTasks.indexWhere((s) => s.id == subTaskId);

        if (subTaskIndex != -1) {
          final oldSubTask = cachedTask.subTasks[subTaskIndex];

          cachedTask.subTasks[subTaskIndex] = oldSubTask.copyWith(
            title: title ?? oldSubTask.title,
            isDone: isDone ?? oldSubTask.isDone,
            updatedAt: DateTime.now(),
          );

          await _updateTaskInCache(cachedTask);
          return cachedTask;
        }
      }
    } catch (_) {}

    rethrow;
  }
}

  // Future<TaskModel> getTaskById(int taskId) async {
  //   try {
  //     // Check cache first
  //     final cacheKey = 'task_$taskId';
  //     final isCacheValid = await _secureStorage.isCacheValid(key: cacheKey);
      
  //     if (isCacheValid) {
  //       final cachedTask = await _getCachedTaskById(taskId);
  //       if (cachedTask != null) {
  //         print('Loaded task $taskId from cache');
  //         return cachedTask;
  //       }
  //     }
      
  //     // Fetch from API
  //     final task = await _tasksApi.getTaskById(taskId);
      
  //     // Update this task in cache
  //     await _updateTaskInCache(task);
      
  //     return task;
  //   } catch (e) {
  //     print('Error getting task by id: $e');
      
  //     // Try cache as fallback
  //     final cachedTask = await _getCachedTaskById(taskId);
  //     if (cachedTask != null) {
  //       print('Falling back to cached task $taskId');
  //       return cachedTask;
  //     }
      
  //     rethrow;
  //   }
  // }


Future<TaskModel> createTask({
  required String title,
  required String description,
  required DateTime startTime,
  DateTime? deadline,
  List<SubTaskModel> subTasks = const [],
  String status = 'PROGRESS',
  // ✅ RECURRENCE PARAMETERS
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
      subTasks: subTasks,
      status: status,
      // ✅ PASS TO API
      recurrenceType: recurrenceType,
      recurrenceInterval: recurrenceInterval,
      recurrenceDays: recurrenceDays,
      recurrenceDayOfMonth: recurrenceDayOfMonth,
      recurrenceEndDate: recurrenceEndDate,
    );
    
    await _addTaskToCache(task);
    return task;
  } catch (e) {
    print('Error creating task: $e');
    rethrow;
  }
}

  // Future<void> deleteTask(taskId){
  //   try {



  //   } catch(e){
  //     print(e.toString());
  //   }
  // }

  Future<TaskModel> updateTaskStatus({
    required int taskId,
    required String status,
  }) async {
    try {
      final task = await _tasksApi.updateTaskStatus(
        taskId: taskId,
        status: status,
      );
      
      // Update task in cache
      await _updateTaskInCache(task);
      
      return task;
    } catch (e) {
      print('Error updating task status: $e');
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
      
      // Update parent task in cache
      await _updateSubTaskInCache(taskId, subTaskId, isDone);
      
      return subTask;
    } catch (e) {
      print(' Error updating subtask status: $e');
      rethrow;
    }
  }

  // Future<TaskStats> getTaskStats() async {
  //   try {
  //     // Check cache
  //     final cacheKey = 'task_stats';
  //     final isCacheValid = await _secureStorage.isCacheValid(key: cacheKey);
      
  //     if (isCacheValid) {
  //       final cachedStats = await _getCachedTaskStats();
  //       if (cachedStats != null) {
  //         print('Loading stats from cache');
  //         return cachedStats;
  //       }
  //     }
      
  //     // Fetch from API
  //     final stats = await _tasksApi.getTaskStats();
      
  //     // Cache the stats
  //     await _cacheTaskStats(stats);
      
  //     return stats;
  //   } catch (e) {
  //     print('Error getting task stats: $e');
      
  //     // Try cache as fallback
  //     final cachedStats = await _getCachedTaskStats();
  //     if (cachedStats != null) {
  //       print('Falling back to cached stats');
  //       return cachedStats;
  //     }
      
  //     rethrow;
  //   }
  // }

  Future<void> deleteTask(int taskId) async {
    try {
      await _tasksApi.deleteTask(taskId);
      
      // Remove task from cache
      await _removeTaskFromCache(taskId);
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // Cache helper methods
  String _generateCacheKey({String? status, DateTime? date}) {
    final parts = ['all_tasks'];
    
    if (status != null) {
      parts.add('status_${status.toLowerCase()}');
    }
    
    if (date != null) {
      parts.add('date_${date.toIso8601String().split('T')[0]}');
    }
    
    return parts.join('_');
  }

  Future<void> _cacheTasks(List<TaskModel> tasks, String cacheKey) async {
    try {
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      await _secureStorage.cacheData(
        key: cacheKey,
        data: tasksJson,
        dataType: 'tasks',
      );
      
      print('Cached ${tasks.length} tasks with key: $cacheKey');
    } catch (e) {
      print('Error caching tasks: $e');
    }
  }

  Future<List<TaskModel>> _getCachedTasks(String cacheKey) async {
    try {
      final cachedData = await _secureStorage.getCachedData(
        key: cacheKey,
        dataType: 'tasks',
      );
      
      if (cachedData == null || cachedData.isEmpty) {
        return [];
      }
      
      final tasksJson = cachedData as List<dynamic>;
      return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      print('Error reading cached tasks: $e');
      return [];
    }
  }

  Future<TaskModel?> _getCachedTaskById(int taskId) async {
    try {
      // Get all tasks from cache and find the specific one
      final allTasksKey = _generateCacheKey();
      final cachedTasks = await _getCachedTasks(allTasksKey);
      
      return cachedTasks.firstWhere(
        (task) => task.id == taskId,
        orElse: () => throw Exception('Task not found in cache'),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateTaskInCache(TaskModel updatedTask) async {
    try {
      // Get all cached tasks
      final allTasksKey = _generateCacheKey();
      final cachedTasks = await _getCachedTasks(allTasksKey);
      
      // Find and update the task
      final taskIndex = cachedTasks.indexWhere((task) => task.id == updatedTask.id);
      if (taskIndex != -1) {
        cachedTasks[taskIndex] = updatedTask;
        await _cacheTasks(cachedTasks, allTasksKey);
        print('Updated task ${updatedTask.id} in cache');
      }
    } catch (e) {
      print(' Error updating task in cache: $e');
    }
  }

  Future<void> _addTaskToCache(TaskModel newTask) async {
    try {
      final allTasksKey = _generateCacheKey();
      final cachedTasks = await _getCachedTasks(allTasksKey);
      
      cachedTasks.add(newTask);
      await _cacheTasks(cachedTasks, allTasksKey);
      print('Added new task ${newTask.id} to cache');
    } catch (e) {
      print(' Error adding task to cache: $e');
    }
  }

  Future<void> _removeTaskFromCache(int taskId) async {
    try {
      final allTasksKey = _generateCacheKey();
      final cachedTasks = await _getCachedTasks(allTasksKey);
      
      final updatedTasks = cachedTasks.where((task) => task.id != taskId).toList();
      await _cacheTasks(updatedTasks, allTasksKey);
      print('Removed task $taskId from cache');
    } catch (e) {
      print(' Error removing task from cache: $e');
    }
  }

  Future<void> _updateSubTaskInCache(int taskId, int subTaskId, bool isDone) async {
    try {
      final task = await _getCachedTaskById(taskId);
      if (task != null) {
        final subTaskIndex = task.subTasks.indexWhere((sub) => sub.id == subTaskId);
        if (subTaskIndex != -1) {
          task.subTasks[subTaskIndex] = SubTaskModel(
            id: subTaskId,
            title: task.subTasks[subTaskIndex].title,
            isDone: isDone,
            taskId: taskId,
            createdAt: task.subTasks[subTaskIndex].createdAt,
            updatedAt: DateTime.now(),
          );
          
          await _updateTaskInCache(task);
          print('Updated subtask $subTaskId in cache');
        }
      }
    } catch (e) {
      print('Error updating subtask in cache: $e');
    }
  }



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
    final task = await _tasksApi.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      startTime: startTime,
      deadline: deadline,
      subTasks: subTasks,
      status: status,
      // ✅ PASS TO API
      recurrenceType: recurrenceType,
      recurrenceInterval: recurrenceInterval,
      recurrenceDays: recurrenceDays,
      recurrenceDayOfMonth: recurrenceDayOfMonth,
      recurrenceEndDate: recurrenceEndDate,
    );
    
    await _updateTaskInCache(task);
    return task;
  } catch (e) {
    print('Error updating task: $e');
    rethrow;
  }
}

  // Future<void> _cacheTaskStats(TaskStats stats) async {
  //   try {
  //     // Convert TaskStats to a Map for caching
  //     final statsMap = _taskStatsToMap(stats);
  //     await _secureStorage.cacheData(
  //       key: 'task_stats',
  //       data: statsMap,
  //       dataType: 'stats',
  //     );
  //     print('Cached task stats');
  //   } catch (e) {
  //     print('Error caching task stats: $e');
  //   }
  // }

  // Future<TaskStats?> _getCachedTaskStats() async {
  //   try {
  //     final cachedData = await _secureStorage.getCachedData(
  //       key: 'task_stats',
  //       dataType: 'stats',
  //     );
      
  //     if (cachedData == null) {
  //       return null;
  //     }
      
  //     final statsMap = cachedData as Map<String, dynamic>;
  //     return _mapToTaskStats(statsMap);
  //   } catch (e) {
  //     print('Error reading cached stats: $e');
  //     return null;
  //   }
  // }

  // // Helper methods for TaskStats serialization
  // Map<String, dynamic> _taskStatsToMap(TaskStats stats) {
  //   return {
  //     'totalTasks': stats.totalTasks,
  //     'completedTasks': stats.completedTasks,
  //     'pendingTasks': stats.pendingTasks,
  //     'overdueTasks': stats.overdueTasks,
  //   };
  // }

  // TaskStats _mapToTaskStats(Map<String, dynamic> map) {
  //   return TaskStats(
  //     totalTasks: map['totalTasks'] ?? 0,
  //     completedTasks: map['completedTasks'] ?? 0,
  //     pendingTasks: map['pendingTasks'] ?? 0,
  //     overdueTasks: map['overdueTasks'] ?? 0,
  //   );
  // }

  // Clear all task-related cache
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