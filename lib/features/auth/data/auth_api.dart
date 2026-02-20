import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/features/auth/models/user_model.dart';

class AuthApi {
  final DioClient _dioClient;
  
  AuthApi(this._dioClient);
  
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String auth_provider
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: RegisterRequest(
          name: name,
          email: email,
          imageUrl: '',
          password: password,
          authProvider:auth_provider
        ).toJson(),
      );
      
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> changePassword({
    required String currentPassword, 
    required String newPassword
  }) async {
    try {
      final response  = await _dioClient.dio.patch(
        ApiEndpoints.updatePassword,
        data:  {
          "currentPassword": currentPassword,
          "newPassword": newPassword
        }
        
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: LoginRequest(
          email: email,
          password: password,
        ).toJson(),
      );
      
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Future<void> logout() async {
  //   try {
  //     await _dioClient.dio.post(ApiEndpoints.logout);
  //   } on DioException catch (e) {
  //     throw _handleError(e);
  //   }
  // }
  
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  String _handleError(DioException e) {
    if (e.response != null) {
      final errorData = e.response!.data;
      if (errorData is Map<String, dynamic>) {
        return errorData['message'] ?? errorData['error'] ?? 'An error occurred';
      }
      return e.response!.statusMessage ?? 'An error occurred';
    }
    return e.message ?? 'Network error occurred';
  }
}