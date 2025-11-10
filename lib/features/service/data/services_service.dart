import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iosmobileapp/features/service/domain/service.dart';

class ServicesService {
  ServicesService({http.Client? client, String? authToken})
    : _client = client ?? http.Client(),
      _authToken = authToken ?? _defaultToken;

  final http.Client _client;
  final String _authToken;

  static const String _baseUrl =
      'https://paxtech.azurewebsites.net/api/v1/services';
  static const String _defaultToken =
      'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJzdHJpbmc1IiwiaWF0IjoxNzYyNzI1OTUwLCJleHAiOjE3NjMzMzA3NTB9.c30pouhMQDJJxIAMUGi-m0nAvqJ_em0-CRA3zMig9DWGYagvmfC0rkZDSHT1j64q';

  Map<String, String> get _headers => {
    HttpHeaders.authorizationHeader: 'Bearer $_authToken',
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  Future<List<Service>> getServices() async {
    final response = await _client.get(Uri.parse(_baseUrl), headers: _headers);

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
    final payload = request.copyWith(providerId: 1).toJson();
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: _headers,
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
    final uri = Uri.parse('$_baseUrl/$serviceId');
    final payload = request.copyWith(providerId: 1).toJson();
    final response = await _client.put(
      uri,
      headers: _headers,
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
    final uri = Uri.parse('$_baseUrl/$serviceId');
    final response = await _client.delete(uri, headers: _headers);

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
