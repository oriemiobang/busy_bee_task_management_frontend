import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/core/storage/secure_storage.dart';

class ApiInterceptors extends Interceptor {
  final SecureStorage _secureStorage = SecureStorage();
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from storage
    final token = await _secureStorage.getAccessToken();
    
    // Add authorization header if token exists
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized errors (token expired)
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken != null) {
          // Call refresh token endpoint
          final response = await Dio().post(
            '${err.requestOptions.baseUrl}${ApiEndpoints.refreshToken}',
            data: {'refreshToken': refreshToken},
          );
          
          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'];
            await _secureStorage.saveAccessToken(newAccessToken);
            
            // Retry the original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await Dio().fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // If refresh fails, clear storage
        await _secureStorage.clearAll();
        throw Exception('Session expired. Please login again.');
      }
    }
    
    return handler.next(err);
  }
}