// // lib/core/providers/app_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:frontend/core/network/dio_client.dart';
// import 'package:frontend/core/storage/secure_storage.dart';
// import 'package:frontend/features/auth/data/auth_api.dart';
// import 'package:frontend/features/auth/data/auth_repository.dart';
// import 'package:frontend/features/auth/state/auth_provider.dart';
// import 'package:frontend/features/dashboard/data/tasks_api.dart';
// import 'package:frontend/features/dashboard/data/tasks_repository.dart';
// import 'package:frontend/features/dashboard/state/tasks_provider.dart';

// class AppProvider extends ChangeNotifier {
//   // App state
//   bool _isInitialized = false;
//   bool _isLoading = true;
//   String? _error;
  
//   // Core dependencies
//   late final DioClient _dioClient;
//   late final SecureStorage _secureStorage;
  
//   // APIs
//   late final AuthApi _authApi;
//   late final TasksApi _tasksApi;
  
//   // Repositories
//   late final AuthRepository _authRepository;
//   late final TasksRepository _tasksRepository;
  
//   // Feature providers
//   late final AuthProvider _authProvider;
//   late final TasksProvider _tasksProvider;
  
//   AppProvider() {
//     _initialize();
//   }
  
//   bool get isInitialized => _isInitialized;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   AuthProvider get authProvider => _authProvider;
//   TasksProvider get tasksProvider => _tasksProvider;
  
//   Future<void> _initialize() async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();
      
//       print('🚀 Initializing App...');
      
//       // Initialize core dependencies
//       _dioClient = DioClient();
//       _secureStorage = SecureStorage();
//       print('✅ Core dependencies initialized');
      
//       // Initialize APIs
//       _authApi = AuthApi(_dioClient);
//       _tasksApi = TasksApi(_dioClient);
//       print('✅ APIs initialized');
      
//       // Initialize repositories
//       _authRepository = AuthRepository(
//         authApi: _authApi,
//         secureStorage: _secureStorage,
//       );
//       _tasksRepository = TasksRepository(_tasksApi, _secureStorage); // Fixed: Added secureStorage
//       print('✅ Repositories initialized');
      
//       // Initialize providers
//       _authProvider = AuthProvider(_authRepository);
//       _tasksProvider = TasksProvider(_tasksRepository);
//       print('✅ Providers initialized');
      
//       // Check authentication status on startup
//       print('🔐 Checking authentication status...');
//       await _authProvider.checkAuthStatus();
      
//       // If authenticated, preload tasks
//       if (_authProvider.isAuthenticated) {
//         print('👤 User is authenticated, preloading tasks...');
//         await _tasksProvider.ensureTasksLoaded();
//       }
      
//       _isInitialized = true;
//       _isLoading = false;
//       print('🎉 App initialization complete!');
//       notifyListeners();
      
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       _isInitialized = true; // Mark as initialized even on error
      
//       if (kDebugMode) {
//         print('❌ App initialization error: $e');
//       }
      
//       notifyListeners();
//       rethrow;
//     }
//   }
  
//   // Global logout
//   Future<void> globalLogout() async {
//     try {
//       await _authProvider.logout();
//       _tasksProvider.clearTasks();
//       // Clear cache on logout
//       await _secureStorage.clearAllCache();
//       print('👋 Global logout complete');
//       notifyListeners();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error during global logout: $e');
//       }
//       rethrow;
//     }
//   }
  
//   // Refresh app state
//   Future<void> refreshApp() async {
//     try {
//       _isLoading = true;
//       notifyListeners();
      
//       // Refresh auth status
//       await _authProvider.checkAuthStatus();
      
//       // If authenticated, refresh tasks
//       if (_authProvider.isAuthenticated) {
//         await _tasksProvider.fetchTasks(refresh: true);
//       } else {
//         _tasksProvider.clearTasks();
//       }
      
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }
  
//   // Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }