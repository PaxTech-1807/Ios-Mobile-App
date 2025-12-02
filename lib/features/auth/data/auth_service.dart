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

    print('📝 [AuthService] Intentando registrar usuario...');
    print('📧 [AuthService] Email: $email');
    print('🌐 [AuthService] URL: $uri');

    try {
      final response = await _client.post(uri, headers: _headers, body: body);

      print('📊 [AuthService] Status Code: ${response.statusCode}');
      print('📄 [AuthService] Response Body: ${response.body}');

      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          print('✅ [AuthService] Registro exitoso');
          return SignUpResponse.fromJson(decoded);
        } catch (e) {
          print('❌ [AuthService] Error parseando respuesta: $e');
          throw Exception(
            'Error al procesar la respuesta del servidor. El servidor respondió con código ${response.statusCode}, pero la respuesta no es válida: ${response.body}',
          );
        }
      }

      // Intentar obtener el mensaje de error del servidor
      String errorMessage = 'Error desconocido';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map<String, dynamic>) {
          errorMessage = errorBody['message'] ?? 
                        errorBody['error'] ?? 
                        errorBody['title'] ?? 
                        response.body;
        } else {
          errorMessage = response.body;
        }
      } catch (e) {
        errorMessage = response.body.isNotEmpty 
            ? response.body 
            : 'Error ${response.statusCode}: ${_getStatusMessage(response.statusCode)}';
      }

      print('❌ [AuthService] Error del servidor: $errorMessage');
      
      throw Exception(
        'Error al registrarse (${response.statusCode}): $errorMessage',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      print('💥 [AuthService] Excepción no esperada: $e');
      throw Exception('Error de conexión: $e');
    }
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

    print('🔐 [AuthService] Intentando iniciar sesión...');
    print('📧 [AuthService] Email: $email');
    print('🌐 [AuthService] URL: $uri');
    print('📝 [AuthService] Headers: $_headers');
    print('📦 [AuthService] Body: $body');

    try {
      final response = await _client.post(uri, headers: _headers, body: body);

      print('📊 [AuthService] Status Code: ${response.statusCode}');
      print('📄 [AuthService] Response Body: ${response.body}');
      print('📋 [AuthService] Response Headers: ${response.headers}');

      if (response.statusCode == HttpStatus.ok) {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          print('✅ [AuthService] Login exitoso');
          return SignInResponse.fromJson(decoded);
        } catch (e) {
          print('❌ [AuthService] Error parseando respuesta: $e');
          throw Exception(
            'Error al procesar la respuesta del servidor. El servidor respondió con código ${response.statusCode}, pero la respuesta no es válida: ${response.body}',
          );
        }
      }

      // Intentar obtener el mensaje de error del servidor
      String errorMessage = 'Error desconocido';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map<String, dynamic>) {
          errorMessage = errorBody['message'] ?? 
                        errorBody['error'] ?? 
                        errorBody['title'] ?? 
                        response.body;
        } else {
          errorMessage = response.body;
        }
      } catch (e) {
        // Si no se puede parsear, usar el body directamente
        errorMessage = response.body.isNotEmpty 
            ? response.body 
            : 'Error ${response.statusCode}: ${_getStatusMessage(response.statusCode)}';
      }

      print('❌ [AuthService] Error del servidor: $errorMessage');
      
      throw Exception(
        'Error al iniciar sesión (${response.statusCode}): $errorMessage',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      print('💥 [AuthService] Excepción no esperada: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud inválida';
      case 401:
        return 'Credenciales incorrectas';
      case 403:
        return 'Acceso denegado';
      case 404:
        return 'Endpoint no encontrado';
      case 500:
        return 'Error interno del servidor';
      default:
        return 'Error desconocido';
    }
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

