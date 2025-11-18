import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iosmobileapp/core/services/onboarding_service.dart';

class ClientInfo {
  final int id;
  final String firstName;
  final String lastName;
  final int userId;
  final String? profileImageUrl;

  ClientInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userId,
    this.profileImageUrl,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      userId: json['userId'] as int,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class ClientService {
  ClientService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final _onboardingService = OnboardingService();

  static const String _baseUrl =
      'https://paxtech.azurewebsites.net/api/v1/clients';

  Future<Map<String, String>> get _headers async {
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

  Future<ClientInfo> getClientById(int clientId) async {
    final headers = await _headers;
    final uri = Uri.parse('$_baseUrl/$clientId');
    
    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ClientInfo.fromJson(decoded);
    }

    throw HttpException(
      'Failed to load client $clientId. Status code: ${response.statusCode}',
      uri: uri,
    );
  }

  Future<Map<int, ClientInfo>> getClientsByIds(List<int> clientIds) async {
    final Map<int, ClientInfo> clients = {};
    
    // Obtener información de clientes en paralelo
    final futures = clientIds.map((id) async {
      try {
        final client = await getClientById(id);
        return MapEntry(id, client);
      } catch (e) {
        // Si falla, no agregar al mapa
        return null;
      }
    });

    final results = await Future.wait(futures);
    for (final result in results) {
      if (result != null) {
        clients[result.key] = result.value;
      }
    }

    return clients;
  }
}

