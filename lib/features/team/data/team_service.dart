import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/team/domain/worker.dart';

class TeamService {
  TeamService({http.Client? client, String? authToken})
    : _client = client ?? http.Client(),
      _authToken = authToken,
      _onboardingService = OnboardingService();

  final http.Client _client;
  final String? _authToken;
  final OnboardingService _onboardingService;

  static const String _baseUrl =
      'https://paxtech.azurewebsites.net/api/v1/workers';

  Future<Map<String, String>> get _headers async {
    // Siempre obtener el token más reciente del OnboardingService
    final token = await _onboardingService.getJwtToken();
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

  Future<List<Worker>> getWorkers() async {
    final headers = await _headers;
    final response = await _client.get(Uri.parse(_baseUrl), headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => Worker.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    if (response.statusCode == HttpStatus.notFound) {
      return <Worker>[];
    }

    throw HttpException(
      'Failed to load workers. Status code: ${response.statusCode}',
      uri: Uri.parse(_baseUrl),
    );
  }

  Future<Worker> getWorker(int workerId) async {
    final headers = await _headers;
    final uri = Uri.parse('$_baseUrl/$workerId');
    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      return Worker.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw HttpException(
      'Failed to load worker $workerId. Status code: ${response.statusCode}',
      uri: uri,
    );
  }

  Future<Worker> createWorker(WorkerRequest request) async {
    final headers = await _headers;
    
    // Verificar que el token esté presente
    if (!headers.containsKey(HttpHeaders.authorizationHeader)) {
      throw HttpException(
        'No se pudo obtener el token de autenticación',
        uri: Uri.parse(_baseUrl),
      );
    }
    
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      return Worker.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    // Si es 401, el token puede estar expirado o ser inválido
    if (response.statusCode == HttpStatus.unauthorized) {
      throw HttpException(
        'No autorizado. El token puede haber expirado. Por favor inicia sesión nuevamente.',
        uri: Uri.parse(_baseUrl),
      );
    }

    throw HttpException(
      'Failed to create worker. Status code: ${response.statusCode}',
      uri: Uri.parse(_baseUrl),
    );
  }

  Future<Worker> updateWorker({
    required int workerId,
    required WorkerRequest request,
  }) async {
    final headers = await _headers;
    final uri = Uri.parse('$_baseUrl/$workerId');
    final response = await _client.put(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == HttpStatus.ok) {
      return Worker.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw HttpException(
      'Failed to update worker $workerId. Status code: ${response.statusCode}',
      uri: uri,
    );
  }

  Future<void> deleteWorker(int workerId) async {
    final headers = await _headers;
    final uri = Uri.parse('$_baseUrl/$workerId');
    final response = await _client.delete(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.noContent) {
      return;
    }

    throw HttpException(
      'Failed to delete worker $workerId. Status code: ${response.statusCode}',
      uri: uri,
    );
  }
}
