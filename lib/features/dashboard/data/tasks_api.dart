import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
import 'package:frontend/features/dashboard/model/task_stats.dart';


class TasksApi {
  final DioClient _dioClient;

  TasksApi(this._dioClient);

Future<List<TaskModel>> getTasks({

  String? status,
  DateTime? date,
}) async {
  try {
    print('Fetching ALL tasks from: ${ApiEndpoints.tasks}');
    
    final response = await _dioClient.dio.get(
      ApiEndpoints.tasks,
      queryParameters: {
   
        if (status != null) 'status': status,
        if (date != null) 'date': date.toIso8601String(),
      },
    );

    print('Response status: ${response.statusCode}');
    
    // Handle 404 or empty response
    if (response.statusCode == 404 || response.data == null) {
      print('ℹNo tasks found, returning empty list');
      return [];
    }
    
    // Check if response.data is a Map with 'message' field
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('message') && data['message'] == 'No tasks found') {
        print('"No tasks found" message, returning empty list');
        return [];
      }
    }
    
    // Try to parse as List
    if (response.data is List) {
      final tasks = (response.data as List)
          .map((taskJson) => TaskModel.fromJson(taskJson))
          .toList();
      
      print('Successfully parsed ${tasks.length} tasks');
      return tasks;
    }


    
    // If it's a Map with 'data' field
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('data') && data['data'] is List) {
        final tasks = (data['data'] as List)
            .map((taskJson) => TaskModel.fromJson(taskJson))
            .toList();
        print(' Parsed ${tasks.length} tasks from "data" field');
        return tasks;
      }
    }
    
    print('Unexpected response format, returning empty list');
    return [];

  } on DioException catch (e) {
    print('Dio error: ${e.message}');
    print('Status: ${e.response?.statusCode}');
    
    // Handle 404 as empty list
    if (e.response?.statusCode == 404) {
      print('ℹNo tasks found (404), returning empty list');
      return [];
    }
    
    throw _handleError(e);
  } catch (e) {
    print(' Unexpected error: $e');
    return [];
  }
}


Future<TaskModel> updateSubTask({
  required int taskId,
  required int subTaskId,
  String? title,
  bool? isDone,
}) async {
  final response = await _dioClient.dio.patch(
    '/tasks/$taskId/subtasks/$subTaskId',
    data: {
      if (title != null) 'title': title,
      if (isDone != null) 'isDone': isDone,
    },
  );

  return TaskModel.fromJson(response.data);
}

// Remove getTodaysTasks() method since you don't need it
  Future<List<TaskModel>> getTodaysTasks() async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.tasks,
      );

      return (response.data as List)
          .map((taskJson) => TaskModel.fromJson(taskJson))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TaskModel> getTaskById(int taskId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiEndpoints.tasks}/$taskId',
      );

      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

// REPLACE your createTask method with this FIXED version
// REPLACE createTask method
// REPLACE createTask method
Future<TaskModel> createTask({
  required String title,
  required String description,
  required DateTime startTime,
  DateTime? deadline,
 required List<SubTaskModel> subtasks,
  String status = 'PROGRESS',
  String? recurrenceType,
  int? recurrenceInterval,
  List<String>? recurrenceDays,
  int? recurrenceDayOfMonth,
  DateTime? recurrenceEndDate,
}) async {
  try {
    // ✅ CRITICAL: Backend expects SINGULAR "subTask" field with specific structure
    final subTaskPayload = subtasks.map((s) => {
      'title': s.title,
      'isDone': s.isDone, // ✅ Must be boolean (not null)
    }).toList();

    final response = await _dioClient.dio.post(
      ApiEndpoints.addTask,
      data: {
        'title': title,
        'description': description,
        'start_time': startTime.toIso8601String(),
        if (deadline != null) 'deadline': deadline.toIso8601String(),
        'status': status,
        'sort_order': 1, // Required by backend
        
        // ✅ RECURRENCE FIELDS (match Prisma schema exactly)
        if (recurrenceType != null) 'recurrenceType': recurrenceType,
        if (recurrenceInterval != null) 'recurrenceInterval': recurrenceInterval,
        if (recurrenceDays != null && recurrenceDays.isNotEmpty) 
          'recurrenceDays': recurrenceDays,
        if (recurrenceDayOfMonth != null) 'recurrenceDayOfMonth': recurrenceDayOfMonth,
        if (recurrenceEndDate != null) 
          'recurrenceEndDate': recurrenceEndDate.toIso8601String(),
        
        // ✅ SUBTASKS: Singular field name + proper structure
        'subtasks': subTaskPayload, // NOT 'subtasks'!
      },
    );

    return TaskModel.fromJson(response.data);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
// REPLACE updateTask method
Future<TaskModel> updateTask({
  required int taskId,
  String? title,
  String? description,
  DateTime? startTime,
  DateTime? deadline,
  List<SubTaskModel>? subtasks,
  String? status,
  // ✅ RECURRENCE PARAMETERS
  String? recurrenceType,
  int? recurrenceInterval,
  List<String>? recurrenceDays,
  int? recurrenceDayOfMonth,
  DateTime? recurrenceEndDate,
}) async {
  try {
    final data = <String, dynamic>{};
    
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (startTime != null) data['start_time'] = startTime.toIso8601String();
    if (deadline != null) data['deadline'] = deadline.toIso8601String();
    if (status != null) data['status'] = status;
    
    // ✅ CONDITIONALLY ADD RECURRENCE FIELDS
    if (recurrenceType != null) data['recurrenceType'] = recurrenceType;
    if (recurrenceInterval != null) data['recurrenceInterval'] = recurrenceInterval;
    if (recurrenceDays != null) data['recurrenceDays'] = recurrenceDays;
    if (recurrenceDayOfMonth != null) data['recurrenceDayOfMonth'] = recurrenceDayOfMonth;
    if (recurrenceEndDate != null) {
      data['recurrenceEndDate'] = recurrenceEndDate.toIso8601String();
    }
    
    // Subtasks update
    if (subtasks != null) {
      data['subtasks'] = subtasks.map((s) => {
        'id': s.id,
        'title': s.title,
        'isDone': s.isDone,
      }).toList();
    }

    final response = await _dioClient.dio.patch(
      '${ApiEndpoints.tasks}/$taskId',
      data: data,
    );

    return TaskModel.fromJson(response.data);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

//  CRITICAL FIX: Handle array error messages from backend
String _handleError(DioException e) {
  if (e.response != null) {
    final errorData = e.response!.data;
    
    // Handle array messages (backend returns ["error1", "error2"])
    if (errorData is Map<String, dynamic>) {
      final message = errorData['message'];
      
      if (message is String) {
        return message;
      } else if (message is List) {
        // Join validation errors into readable string
        return message.map((e) => e.toString()).join(', ');
      }
      
      return errorData['error']?.toString() ?? 'Request failed';
    }
    
    return e.response!.statusMessage ?? 'Request failed';
  }
  
  return e.message ?? 'Network error';
}



  Future<TaskModel> updateTaskStatus({
    required int taskId,
    required String status,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        '${ApiEndpoints.tasks}/$taskId/status',
        data: {'status': status},
      );

      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SubTaskModel> updateSubTaskStatus({
    required int taskId,
    required int subTaskId,
    required bool isDone,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        '${ApiEndpoints.tasks}/$taskId/subtasks/$subTaskId',
        data: {'isDone': isDone},
      );

      return SubTaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Future<TaskStats> getTaskStats() async {
  //   try {
  //     final response = await _dioClient.dio.get(
  //       ApiEndpoints.taskStats,
  //     );

  //     return TaskStats.fromJson(response.data);
  //   } on DioException catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  Future<void> deleteTask(int taskId) async {
    try {
      await _dioClient.dio.delete('${ApiEndpoints.delete}/$taskId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


}