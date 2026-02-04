// lib/features/auth/state/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  // State
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  AuthProvider(this._authRepository);

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  // ✅ Helper for UI components (DashboardHeader, etc.)
  String? get profileImage => _user?.imageUrl ?? _user?.imageUrl;

  // Private setters
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    if (_error == error) return;
    _error = error;
    notifyListeners();
  }
  
  void _setUser(UserModel? user) {
    if (_user?.id == user?.id) return; // Prevent unnecessary rebuilds
    _user = user;
    notifyListeners();
  }
  
  void _setInitialized(bool initialized) {
    if (_isInitialized == initialized) return;
    _isInitialized = initialized;
    notifyListeners();
  }

  // ✅ Initialize auth state (call at app startup)
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await checkAuthStatus();
    } catch (e) {
      if (kDebugMode) {
        print('AuthProvider initialization error (non-fatal): $e');
      }
      // Don't rethrow - initialization must complete to unblock router
    } finally {
      _setInitialized(true); // ✅ ALWAYS mark initialized (critical for router)
    }
  }

  // ✅ Fixed null safety: user might be null after getCurrentUser()
  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        _setUser(user);
        
        if (kDebugMode) {
          final userName = user?.name ?? 'Unknown';
          final userId = user?.id ?? 'N/A';
          print('✅ Auth check: User authenticated - $userName ($userId)');
        }
      } else {
        _setUser(null);
        if (kDebugMode) {
          print('✅ Auth check: No authenticated user');
        }
      }
      
      _setLoading(false);
    } catch (e, stackTrace) {
      _setError(e.toString());
      _setLoading(false);
      
      if (kDebugMode) {
        print('❌ Auth check error: $e');
        print('Stack trace: $stackTrace');
      }
      // Don't rethrow - allow app to proceed with guest experience
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      if (kDebugMode) {
        print('🔄 Attempting login for: $email');
      }
      
      final response = await _authRepository.login(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('✅ Login successful');
        print('User ID: ${response.user.id}');
        print('Has token: ${response.hasTokens}');
      }
      
      _setUser(response.user);
      _setLoading(false);
      
      if (kDebugMode) {
        print('🏁 Login process completed');
      }
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Login error: $e');
        print('Stack trace: $stackTrace');
      }
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String authProvider = 'email',
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      if (kDebugMode) {
        print('🔄 Attempting registration for: $email');
      }
      
      final response = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        auth_provider: authProvider,
      );
      
      if (kDebugMode) {
        print('✅ Registration successful');
        print('User ID: ${response.user.id}');
      }
      
      if (!response.hasTokens) {
        if (kDebugMode) {
          print('🔄 No tokens from registration, attempting auto-login...');
        }
        await login(email: email, password: password);
      } else {
        _setUser(response.user);
      }
      
      _setLoading(false);
      
      if (kDebugMode) {
        print('🏁 Registration process completed');
      }
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Registration error: $e');
        print('Stack trace: $stackTrace');
      }
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authRepository.logout();
      _setUser(null);
      _setLoading(false);
      
      if (kDebugMode) {
        print('👋 User logged out successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Logout error: $e');
        print('Stack trace: $stackTrace');
      }
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  Future<void> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authRepository.forgotPassword(email);
      
      _setLoading(false);
      
      if (kDebugMode) {
        print('✅ Forgot password request sent for: $email');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Forgot password error: $e');
        print('Stack trace: $stackTrace');
      }
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  void clearError() {
    _setError(null);
  }
}