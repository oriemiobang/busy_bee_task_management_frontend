import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/core/network/dio_client.dart';

class AccountApi {
  final DioClient _dioClient;

  AccountApi(this._dioClient);

  Future<void> updateUserName(String newName) async {
    try {
      await _dioClient.dio.patch(
        ApiEndpoints.user,
        data: {'name': newName},
      );
    } on DioException catch (e) {
      print('Account API error: ${e.message}');
      rethrow;
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dioClient.dio.patch(
        ApiEndpoints.updatePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      print('Password API error: ${e.message}');
      rethrow;
    }
  }
}