import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
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

  /// Sube una imagen de foto del trabajador al servidor
  /// Retorna el worker actualizado con la nueva URL de la imagen
  /// Acepta XFile para compatibilidad con Web y móvil
  Future<Worker> uploadWorkerPhoto({
    required XFile imageFile,
    required int workerId,
  }) async {
    try {
      print(
        '📤 [TeamService] Subiendo imagen de foto para worker ID: $workerId',
      );

      // Leer bytes del archivo (funciona en web y móvil)
      final bytes = await imageFile.readAsBytes();
      final fileSize = bytes.length;
      final fileSizeMB = fileSize / (1024 * 1024);
      print(
        '📏 [TeamService] Tamaño del archivo: ${fileSizeMB.toStringAsFixed(2)} MB',
      );

      if (fileSize > 5 * 1024 * 1024) {
        throw Exception(
          'La imagen es demasiado grande. Tamaño máximo: 5MB. '
          'Tamaño actual: ${fileSizeMB.toStringAsFixed(2)} MB',
        );
      }

      final token = await _onboardingService.getJwtToken();
      if (token == null || token.isEmpty) {
        throw HttpException(
          'No se encontró token de autenticación.',
          uri: Uri.parse(_baseUrl),
        );
      }

      final uri = Uri.parse('$_baseUrl/$workerId/photo-image');

      print('🌐 [TeamService] POST: $uri');

      var request = http.MultipartRequest('POST', uri);

      // Agregar headers de autenticación
      request.headers['Authorization'] = 'Bearer $token';

      // Detectar el tipo MIME del archivo
      String mimeType = imageFile.mimeType ?? 'image/jpeg';
      print(
        '📎 [TeamService] Tipo de archivo: $mimeType, nombre: ${imageFile.name}',
      );

      // Agregar la imagen usando bytes (compatible con web y móvil)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // nombre del campo esperado por el backend
          bytes,
          filename: imageFile.name,
          contentType: MediaType.parse(mimeType),
        ),
      );

      print('⏳ [TeamService] Enviando imagen...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 [TeamService] Status Code: ${response.statusCode}');
      print('📄 [TeamService] Response: ${response.body}');

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final updatedWorker = Worker.fromJson(json);

        print('✅ [TeamService] Imagen subida exitosamente');
        print(
          '🖼️ [TeamService] Nueva URL: ${updatedWorker.photoUrl}',
        );

        return updatedWorker;
      }

      throw HttpException(
        'Error al subir imagen. Status code: ${response.statusCode}',
        uri: uri,
      );
    } catch (e) {
      print('💥 [TeamService] Error en uploadWorkerPhoto: $e');
      rethrow;
    }
  }
}
