// lib/core/services/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorage {
  final _storage = const FlutterSecureStorage();
  
  // Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String userImageKey = 'user_image';

  
  // Save tokens and user data
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: accessTokenKey, value: token);
  }
  
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: refreshTokenKey, value: token);
  }
  
Future<void> saveUserData({
  required String userId,
  required String email,
  required String name,
  required String imageUrl,
}) async {
  await _storage.write(key: userIdKey, value: userId);
  await _storage.write(key: userEmailKey, value: email);
  await _storage.write(key: userNameKey, value: name);
  await _storage.write(key: userImageKey, value: imageUrl);
}

Future<String?> getUserImage() async {
  return await _storage.read(key: userImageKey);
}

  
  // Cache data with timestamp and type
  Future<void> cacheData({
    required String key,
    required dynamic data,
    required String dataType,
    int maxAgeMinutes = 5,
  }) async {
    try {
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'dataType': dataType,
        'maxAgeMinutes': maxAgeMinutes,
      };
      
      final cacheJson = jsonEncode(cacheData);
      await _storage.write(key: key, value: cacheJson);
    } catch (e) {
      print('❌ Error caching data: $e');
    }
  }
  
  // Get cached data
  Future<dynamic> getCachedData({
    required String key,
    required String dataType,
  }) async {
    try {
      final cacheJson = await _storage.read(key: key);
      if (cacheJson == null) {
        return null;
      }
      
      final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
      
      // Check data type
      if (cacheData['dataType'] != dataType) {
        return null;
      }
      
      return cacheData['data'];
    } catch (e) {
      print('❌ Error reading cached data: $e');
      return null;
    }
  }
  
  // Check if cache is valid
  Future<bool> isCacheValid({
    required String key,
    int? maxAgeMinutes,
  }) async {
    try {
      final cacheJson = await _storage.read(key: key);
      if (cacheJson == null) {
        return false;
      }
      
      final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
      final timestampStr = cacheData['timestamp'] as String?;
      
      if (timestampStr == null) {
        return false;
      }
      
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);
      
      final cacheMaxAge = maxAgeMinutes ?? cacheData['maxAgeMinutes'] ?? 5;
      return difference.inMinutes < cacheMaxAge;
    } catch (e) {
      print('❌ Error checking cache validity: $e');
      return false;
    }
  }
  
  // Clear cache by data type
  Future<void> clearCacheByDataType(String dataType) async {
    try {
      final allKeys = await _storage.readAll();
      
      for (final entry in allKeys.entries) {
        try {
          final cacheJson = entry.value;
          if (cacheJson != null) {
            final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
            if (cacheData['dataType'] == dataType) {
              await _storage.delete(key: entry.key);
            }
          }
        } catch (e) {
          // Skip invalid cache entries
          continue;
        }
      }
    } catch (e) {
      print('❌ Error clearing cache by type: $e');
    }
  }
  
  // Clear all cache
  Future<void> clearAllCache() async {
    try {
      final allKeys = await _storage.readAll();
      
      for (final entry in allKeys.entries) {
        // Don't delete auth tokens
        if (!_isAuthKey(entry.key)) {
          await _storage.delete(key: entry.key);
        }
      }
      print('🧹 All cache cleared (auth tokens preserved)');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
  
  bool _isAuthKey(String key) {
    return key == accessTokenKey ||
           key == refreshTokenKey ||
           key == userIdKey ||
           key == userEmailKey ||
           key == userNameKey;
  }
  
  // Get stored data
  Future<String?> getAccessToken() async {
    return await _storage.read(key: accessTokenKey);
  }
  
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }
  
  Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }
  
  Future<String?> getUserEmail() async {
    return await _storage.read(key: userEmailKey);
  }
  
  Future<String?> getUserName() async {
    return await _storage.read(key: userNameKey);
  }
  
  // Clear all storage (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
    print('🧹 All storage cleared');
  }
}