import 'package:flutter/material.dart';
import 'package:frontend/features/auth/state/auth_provider.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';
import 'package:provider/provider.dart';

class AppInitializationProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(BuildContext context) async {
    // Check auth status
    await context.read<AuthProvider>().checkAuthStatus();
    
    // Preload tasks if authenticated
    if (context.read<AuthProvider>().isAuthenticated) {
      await context.read<TasksProvider>().ensureTasksLoaded();
      await context.read<AuthProvider>().getCurrentUser(); 
    }
    
    _isInitialized = true;
    notifyListeners();
  }
}