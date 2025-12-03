import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/auth/data/auth_service.dart';
import 'package:iosmobileapp/features/service/domain/service.dart';

class ServicesService {
  ServicesService({http.Client? client, String? authToken})
    : _client = client ?? http.Client(),
      _authToken = authToken,
      _onboardingService = OnboardingService();

  final http.Client _client;
  final String? _authToken;
  final OnboardingService _onboardingService;

  static const String _baseUrl =
      'https://paxtech.azurewebsites.net/api/v1/services';

  Future<Map<String, String>> get _headers async {
    final token = _authToken ?? await _onboardingService.getJwtToken();
    if (token == null || token.isEmpty) {
      throw HttpException(
        'No se encontró token de autenticación. Por favor inicia sesión nuevamente.',
        uri: Uri.parse(_baseUrl),
      );
    }
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  Future<List<Service>> getServices() async {
    final headers = await _headers;
    final response = await _client.get(Uri.parse(_baseUrl), headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      if (response.body.isEmpty) {
        return <Service>[];
      }
      final decoded = jsonDecode(response.body);
      if (decoded == null) {
        return <Service>[];
      }

      if (decoded is List) {
        return decoded
            .map((json) => Service.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return <Service>[];
    }
    if (response.statusCode == HttpStatus.notFound) {
      return <Service>[];
    }

    throw HttpException(
      'Failed to load services. Status code: ${response.statusCode}',
      uri: Uri.parse(_baseUrl),
    );
  }

  Future<Service> createService(ServiceRequest request) async {
    final headers = await _headers;
    // Obtener providerId del usuario logueado
    final userId = await _onboardingService.getUserId();
    int? providerId;
    if (userId != null) {
      final token = await _onboardingService.getJwtToken();
      if (token != null) {
        final authService = AuthService();
        final provider = await authService.getProviderByUserId(
          userId: userId,
          token: token,
        );
        providerId = provider?.id;
      }
    }
    
    final payload = request.copyWith(providerId: providerId ?? 1).toJson();
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      return Service.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw HttpException(
      'Failed to create service. Status code: ${response.statusCode}',
      uri: Uri.parse(_baseUrl),
    );
  }

  Future<Service> updateService({
    required int serviceId,
    required ServiceRequest request,
  }) async {
    final headers = await _headers;
    // Obtener providerId del usuario logueado
    final userId = await _onboardingService.getUserId();
    int? providerId;
    if (userId != null) {
      final token = await _onboardingService.getJwtToken();
      if (token != null) {
        final authService = AuthService();
        final provider = await authService.getProviderByUserId(
          userId: userId,
          token: token,
        );
        providerId = provider?.id;
      }
    }
    
    final uri = Uri.parse('$_baseUrl/$serviceId');
    final payload = request.copyWith(providerId: providerId ?? 1).toJson();
    final response = await _client.put(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == HttpStatus.ok) {
      return Service.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw HttpException(
      'Failed to update service $serviceId. Status code: ${response.statusCode}',
      uri: uri,
    );
  }

  Future<void> deleteService(int serviceId) async {
    final headers = await _headers;
    final uri = Uri.parse('$_baseUrl/$serviceId');
    final response = await _client.delete(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.noContent) {
      return;
    }

    throw HttpException(
      'Failed to delete service $serviceId. Status code: ${response.statusCode}',
      uri: uri,
    );
  }
}
