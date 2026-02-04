import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String authProvider;
  final String imageUrl;
  final DateTime? createdAt;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.authProvider,
    this.createdAt,
    required this.imageUrl
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extract auth_provider with different possible key names
    final authProvider = json['auth_provider']?.toString() ?? 
                        json['authProvider']?.toString() ?? 
                        json['provider']?.toString() ?? 
                        'email';
    
    return UserModel(
      id: json['id']?.toString() ?? 
          'unknown_id',
      imageUrl: json['profile_image_url']??'',
      name: json['name']?.toString() ??  
            'User',
      email: json['email']?.toString() ?? '',
      authProvider: authProvider,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url':imageUrl,
      'auth_provider': authProvider,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
  
  // Factory to create user from JWT token (since your backend only returns token)
  factory UserModel.fromJwtToken(String token) {
    try {
      // Decode JWT token to extract user info
      final parts = token.split('.');
      if (parts.length != 3) {
        return UserModel(
          id: 'unknown',
          name: 'User',
          imageUrl: '',
          email: '',
          authProvider: 'email',
        );
      }
      
      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      final payloadJson = jsonDecode(decodedPayload) as Map<String, dynamic>;
      
      return UserModel(
        id: payloadJson['id']?.toString() ?? 'unknown',
        name: payloadJson['name']?.toString() ?? 'User',
        email: payloadJson['email']?.toString() ?? '',
        authProvider: payloadJson['auth_provider']?.toString() ?? 'email',
        imageUrl: payloadJson['profile_image_url']?.toString() ?? 'email',
      );
    } catch (e) {
      print('Failed to decode JWT token: $e');
      return UserModel(
        id: 'unknown',
        name: 'User',
        email: '',
        imageUrl: '',
        authProvider: 'email',
      );
    }
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String authProvider;
  final String imageUrl;
  RegisterRequest({
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.password,
    this.authProvider = 'email',
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'auth_provider': authProvider,
      'profile_image_url':imageUrl
    };
  }
}

class LoginRequest {
  final String email;
  final String password;
  
  LoginRequest({
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  
  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
  
  // Main factory for parsing JSON responses
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print(' Parsing AuthResponse from JSON:');
    print('JSON keys: ${json.keys.toList()}');
    
    // YOUR LOGIN RESPONSE: {"accessToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."}
    // No user object, only accessToken
    
    final hasAccessToken = json.containsKey('accessToken');
    final hasUserObject = json.containsKey('user');
    
    UserModel user;
    String accessToken = '';
    String refreshToken = '';
    
    if (hasAccessToken) {
      accessToken = json['accessToken']?.toString() ?? '';
      refreshToken = json['refreshToken']?.toString() ?? 
                    json['refresh_token']?.toString() ?? '';
      
      // Try to extract user info from JWT token since no user object in response
      if (accessToken.isNotEmpty) {
        user = UserModel.fromJwtToken(accessToken);
      } else if (hasUserObject) {
        // Parse from user object if available
        Map<String, dynamic> userJson;
        if (json['user'] is Map<String, dynamic>) {
          userJson = json['user'] as Map<String, dynamic>;
        } else if (json['user'] is Map) {
          userJson = Map<String, dynamic>.from(json['user'] as Map);
        } else {
          userJson = {};
        }
        user = UserModel.fromJson(userJson);
      } else {
        // Try to get user from root fields
        user = UserModel.fromJson(json);
      }
    } 
    else if (hasUserObject) {
      // Response has user object
      Map<String, dynamic> userJson;
      if (json['user'] is Map<String, dynamic>) {
        userJson = json['user'] as Map<String, dynamic>;
      } else if (json['user'] is Map) {
        userJson = Map<String, dynamic>.from(json['user'] as Map);
      } else {
        userJson = {};
      }
      
      user = UserModel.fromJson(userJson);
      accessToken = json['accessToken']?.toString() ?? 
                   json['token']?.toString() ?? '';
      refreshToken = json['refreshToken']?.toString() ?? '';
    }
    else {
      // Try to extract from root fields (for registration response)
      user = UserModel.fromJson(json);
      accessToken = '';
      refreshToken = '';
    }
    
    return AuthResponse(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
  
  // Flexible constructor for any type of response
  factory AuthResponse.fromRawResponse(dynamic response) {
    print(' RAW RESPONSE TYPE: ${response.runtimeType}');
    
    if (response == null) {
      throw Exception('Response is null');
    }
    
    if (response is String) {
      try {
        final parsed = jsonDecode(response);
        if (parsed is Map<String, dynamic>) {
          return AuthResponse.fromJson(parsed);
        } else {
          // Handle other response types
          return AuthResponse(
            user: UserModel(
              id: 'temp_id',
              imageUrl: '',
              name: 'User',
              email: '',
              authProvider: 'email',
            ),
            accessToken: '',
            refreshToken: '',
          );
        }
      } catch (e) {
        print('Could not parse string as JSON: $e');
        throw Exception('Invalid response format: $response');
      }
    }
    
    if (response is Map<String, dynamic>) {
      return AuthResponse.fromJson(response);
    }
    
    if (response is Map) {
      return AuthResponse.fromJson(Map<String, dynamic>.from(response));
    }
    
    throw Exception('Unknown response type: ${response.runtimeType}');
  }
  
  // Helper method to check if registration was successful
  bool get hasTokens => accessToken.isNotEmpty;
}