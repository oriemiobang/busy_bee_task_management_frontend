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
    required this.imageUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final authProvider =
        json['auth_provider']?.toString() ??
        json['authProvider']?.toString() ??
        json['provider']?.toString() ??
        'email';

    final imageUrl =
        json['profile_image_url']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image_url']?.toString() ??
        '';

    return UserModel(
      id: json['id']?.toString() ?? 'unknown_id',
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      authProvider: authProvider,
      imageUrl: imageUrl,
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
      'auth_provider': authProvider,
      'profile_image_url': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// ✅ FIXED: correctly reads imageUrl from JWT
  factory UserModel.fromJwtToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return UserModel(
          id: 'unknown',
          name: 'User',
          email: '',
          authProvider: 'email',
          imageUrl: '',
        );
      }

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload =
          utf8.decode(base64Url.decode(normalizedPayload));
      final payloadJson =
          jsonDecode(decodedPayload) as Map<String, dynamic>;

      final imageUrl =
          payloadJson['imageUrl']?.toString() ??
          payloadJson['profile_image_url']?.toString() ??
          payloadJson['image_url']?.toString() ??
          '';

      return UserModel(
        id: payloadJson['id']?.toString() ?? 'unknown',
        name: payloadJson['name']?.toString() ?? 'User',
        email: payloadJson['email']?.toString() ?? '',
        authProvider:
            payloadJson['auth_provider']?.toString() ??
            payloadJson['provider']?.toString() ??
            'email',
        imageUrl: imageUrl,
      );
    } catch (e) {
      print('Failed to decode JWT token: $e');
      return UserModel(
        id: 'unknown',
        name: 'User',
        email: '',
        authProvider: 'email',
        imageUrl: '',
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
    required this.name,
    required this.email,
    required this.password,
    required this.imageUrl,
    this.authProvider = 'email',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'auth_provider': authProvider,
      'profile_image_url': imageUrl,
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

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    UserModel user;
    String accessToken = '';
    String refreshToken = '';

    if (json.containsKey('accessToken')) {
      accessToken = json['accessToken']?.toString() ?? '';
      refreshToken =
          json['refreshToken']?.toString() ??
          json['refresh_token']?.toString() ??
          '';

      if (accessToken.isNotEmpty) {
        user = UserModel.fromJwtToken(accessToken);
      } else {
        user = UserModel.fromJson(json);
      }
    } else if (json.containsKey('user')) {
      final userJson =
          Map<String, dynamic>.from(json['user'] as Map);
      user = UserModel.fromJson(userJson);
      accessToken =
          json['accessToken']?.toString() ??
          json['token']?.toString() ??
          '';
      refreshToken = json['refreshToken']?.toString() ?? '';
    } else {
      user = UserModel.fromJson(json);
    }

    return AuthResponse(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  factory AuthResponse.fromRawResponse(dynamic response) {
    if (response is String) {
      return AuthResponse.fromJson(jsonDecode(response));
    }
    if (response is Map<String, dynamic>) {
      return AuthResponse.fromJson(response);
    }
    if (response is Map) {
      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response),
      );
    }
    throw Exception('Unknown response type');
  }

  bool get hasTokens => accessToken.isNotEmpty;
}
