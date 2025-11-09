import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iosmobileapp/features/team/domain/worker.dart';

class TeamService {
  TeamService({http.Client? client, String? authToken})
    : _client = client ?? http.Client(),
      _authToken = authToken ?? _defaultToken;

  final http.Client _client;
  final String _authToken;

  static const String _baseUrl =
      'https://paxtech.azurewebsites.net/api/v1/workers';
  static const String _defaultToken =
      'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJzdHJpbmc1IiwiaWF0IjoxNzYyNzI1OTUwLCJleHAiOjE3NjMzMzA3NTB9.c30pouhMQDJJxIAMUGi-m0nAvqJ_em0-CRA3zMig9DWGYagvmfC0rkZDSHT1j64q';

  Map<String, String> get _headers => {
    HttpHeaders.authorizationHeader: 'Bearer $_authToken',
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  Future<List<Worker>> getWorkers() async {
    final response = await _client.get(Uri.parse(_baseUrl), headers: _headers);

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
    final uri = Uri.parse('$_baseUrl/$workerId');
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == HttpStatus.ok) {
      return Worker.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw HttpException(
      'Failed to load worker $workerId. Status code: ${response.statusCode}',
      uri: uri,
    );
  }

  Future<Worker> createWorker(WorkerRequest request) async {
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      return Worker.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
    final uri = Uri.parse('$_baseUrl/$workerId');
    final response = await _client.put(
      uri,
      headers: _headers,
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
    final uri = Uri.parse('$_baseUrl/$workerId');
    final response = await _client.delete(uri, headers: _headers);

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
