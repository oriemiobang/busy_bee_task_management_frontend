import 'package:frontend/core/storage/secure_storage.dart';
// import 'package:frontend/features/account/api/account_api.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/profile/data/account_api.dart';

class AccountRepository {
  final AccountApi _accountApi;
  final AuthRepository _authRepository;
  final SecureStorage _secureStorage;

  AccountRepository(
    this._accountApi,
    this._authRepository,
    this._secureStorage,
  );

  // Update user name
  Future<void> updateUserName(String newName) async {
    try {
      // 1. Update name via API
      await _accountApi.updateUserName(newName);
      
      // 2. Update stored user data
      final userId = await _secureStorage.getUserId();
      final email = await _secureStorage.getUserEmail();
      final image = await _secureStorage.getUserImage();
      
      if (userId != null && email != null) {
        await _secureStorage.saveUserData(
          userId: userId,
          email: email,
          name: newName,
          imageUrl: image!
        );
      }
      
      print('✅ Name updated successfully');
    } catch (e) {
      print('❌ AccountRepository error: $e');
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // 1. Update password via API
      await _accountApi.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      // 2. Clear auth tokens (user will need to re-login)
      await _secureStorage.clearAll();
      
      print('✅ Password updated successfully, user logged out');
    } catch (e) {
      print('❌ Password update error: $e');
      rethrow;
    }
  }

  // Get current user (from cache)
  Future<UserModel?> getCurrentUser() async {
    return _authRepository.getCurrentUser();
  }

  // Refresh user data from API
  Future<UserModel?> refreshUser() async {
    try {
      final userId = await _secureStorage.getUserId();
      final email = await _secureStorage.getUserEmail();
      final name = await _secureStorage.getUserName();
      
      if (userId == null || email == null || name == null) {
        return null;
      }
      
      return UserModel(
        id: userId,
        name: name,
        imageUrl: '',
        email: email,
        authProvider: 'LOCAL',
      );
    } catch (e) {
      print('❌ Error refreshing user: $e');
      return null;
    }
  }
}