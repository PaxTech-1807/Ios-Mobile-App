import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://paxtech.azurewebsites.net/api/v1';

  Map<String, String> get _headers => {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

  // Sign Up - Crear usuario
  Future<SignUpResponse> signUp({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/authentication/sign-up');
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final response = await _client.post(uri, headers: _headers, body: body);

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return SignUpResponse.fromJson(decoded);
    }

    throw HttpException(
      'Failed to sign up. Status code: ${response.statusCode}',
      uri: uri,
    );
  }

  // Sign In - Iniciar sesión
  Future<SignInResponse> signIn({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/authentication/sign-in');
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final response = await _client.post(uri, headers: _headers, body: body);

    if (response.statusCode == HttpStatus.ok) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return SignInResponse.fromJson(decoded);
    }

    throw HttpException(
      'Failed to sign in. Status code: ${response.statusCode}',
      uri: uri,
    );
  }

  // Crear Provider
  Future<ProviderResponse> createProvider({
    required String companyName,
    required int userId,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/providers');
    final headers = {
      ..._headers,
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    final body = jsonEncode({
      'companyName': companyName,
      'userId': userId,
    });

    final response = await _client.post(uri, headers: headers, body: body);

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ProviderResponse.fromJson(decoded);
    }

    throw HttpException(
      'Failed to create provider. Status code: ${response.statusCode}',
      uri: uri,
    );
  }

  // Obtener Provider por userId
  Future<ProviderResponse?> getProviderByUserId({
    required int userId,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/providers/user/$userId');
    final headers = {
      ..._headers,
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ProviderResponse.fromJson(decoded);
    }

    if (response.statusCode == HttpStatus.notFound) {
      return null;
    }

    throw HttpException(
      'Failed to get provider. Status code: ${response.statusCode}',
      uri: uri,
    );
  }
}

class SignUpResponse {
  final int id;
  final String email;

  SignUpResponse({
    required this.id,
    required this.email,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      id: json['id'] as int,
      email: json['email'] as String,
    );
  }
}

class SignInResponse {
  final int id;
  final String email;
  final String token;

  SignInResponse({
    required this.id,
    required this.email,
    required this.token,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      id: json['id'] as int,
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }
}

class ProviderResponse {
  final int id;
  final String companyName;
  final int userId;

  ProviderResponse({
    required this.id,
    required this.companyName,
    required this.userId,
  });

  factory ProviderResponse.fromJson(Map<String, dynamic> json) {
    return ProviderResponse(
      id: json['id'] as int,
      companyName: json['companyName'] as String,
      userId: json['userId'] as int,
    );
  }
}

