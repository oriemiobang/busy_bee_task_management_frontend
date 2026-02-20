class ApiEndpoints {
  // For Android Emulator: 'http://10.0.2.2:3000/api'
  // For iOS Simulator: 'http://localhost:3000/api'
  // For Physical Device: 'http://YOUR_COMPUTER_IP:3000/api'
// static const String baseUrl = 'http://10.232.89.65:3000';
static const String baseUrl = 'https://busy-bee-task-management-api.onrender.com';
// static const String baseUrl = 'http://10.0.2.2:3000';
  
  // Auth endpoints
  static const String register = '/auth/signup';
  static const String login = '/auth/signin';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String delete = '/tasks/delete-task';
  static  String updateSubTask(String taskId, String subTaskId) => 'https://busy-bee-task-management-api.onrender.com/tasks/update-subTask/$taskId/subtask/$subTaskId';
  // Add this to your existing ApiEndpoints class
static const String productivityStats = '/analytics/dashboard';
static const String addTask = '/tasks/add-task';

// Add these to your existing ApiEndpoints class
static const String user = '/user';
static const String updatePassword = '/auth/update-password';
  // User endpoints
  static const String profile = '/users/profile';
  
  // Task endpoints
  static const String tasks = '/tasks/get-tasks';
  static String taskById(String id) => '/tasks/$id';
  static const String taskStats = '/tasks/stats';
  
  // Dashboard endpoints
  static const String dashboard = '/dashboard';
}