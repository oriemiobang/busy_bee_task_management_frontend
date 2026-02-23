import 'package:flutter/foundation.dart';
// import 'package:frontend/features/account/repository/account_repository.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
import 'package:frontend/features/profile/data/account_repository.dart';

class AccountProvider with ChangeNotifier {
  final AccountRepository _accountRepository;
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;


  AccountProvider(this._accountRepository) {
    _loadUser();
  }

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user data
  Future<void> _loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _accountRepository.getCurrentUser();
      print(' AccountProvider: User loaded - ${_user?.name}');
    } catch (e) {
      _error = 'Failed to load account: ${e.toString()}';
      print(' AccountProvider error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user name
  Future<void> updateUserName(String newName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _accountRepository.updateUserName(newName);
      // Refresh user data
      await _loadUser();
      print(' Name updated to: $newName');
    } catch (e) {
      _error = 'Failed to update name: ${e.toString()}';
      print(' AccountProvider error: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update password
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _accountRepository.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      print(' Password updated successfully');
    } catch (e) {
      _error = 'Failed to update password: ${e.toString()}';
      print(' AccountProvider error: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // Refresh account data
  Future<void> refresh() async {
    await _loadUser();
  }


    Future<void> updateAvatar() async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedUser =
          await _accountRepository.updateAvatar(int.parse(user!.id));

      _user = updatedUser;

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}