import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/auth/data/auth_api.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';
// import 'package:frontend/features/dashboard/state/tasks_provider.dart';

class AuthRepository {
  final AuthApi _authApi;
  final SecureStorage _secureStorage;
 
  
  AuthRepository({
    required AuthApi authApi,
    required SecureStorage secureStorage,
  }) : _authApi = authApi,
       _secureStorage = secureStorage;
  
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String auth_provider
  }) async {
    final response = await _authApi.register(
      name: name,
      email: email,
      password: password,
      auth_provider: auth_provider
    );
    
    // Save tokens and user data
    await _saveAuthData(response);
    
    return response;
  }

  Future<AuthResponse> changePassword({required String currentPassword, required String newPassword}) async{

    final response = await _authApi.changePassword(currentPassword: currentPassword,
     newPassword: newPassword);

     await _saveAuthData(response);
     return response;

  }
  
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _authApi.login(
      email: email,
      password: password,
    );
    
    // Save tokens and user data
    await _saveAuthData(response);
    
    return response;
  }
  
  Future<void> logout() async {
    try {
       
        await _secureStorage.clearAll();
      
      // await _authApi.logout();
    } finally {
    
    }
  }

  
  Future<void> forgotPassword(String email) async {
    await _authApi.forgotPassword(email);
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
Future<UserModel?> getCurrentUser() async {
  final userId = await _secureStorage.getUserId();
  final email = await _secureStorage.getUserEmail();
  final name = await _secureStorage.getUserName();
  final imageUrl = await _secureStorage.getUserImage();

  if (userId == null || email == null || name == null) {
    return null;
  }

  return UserModel(
    id: userId,
    name: name,
    email: email,
    imageUrl: imageUrl ?? '',
    authProvider: 'LOCAL',
  );
}

  
Future<void> _saveAuthData(AuthResponse response) async {
  await _secureStorage.saveAccessToken(response.accessToken);
  await _secureStorage.saveRefreshToken(response.refreshToken);

  await _secureStorage.saveUserData(
    userId: response.user.id,
    email: response.user.email,
    name: response.user.name,
    imageUrl: response.user.imageUrl,
  );
}

}