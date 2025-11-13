// features/calendar/data/timeslot_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/domain/timeslot_request.dart'; // Importar el request

class TimeSlotService {
  TimeSlotService({http.Client? client, String? authToken})
      : _client = client ?? http.Client(),
        _authToken = authToken ?? _defaultToken;

  final http.Client _client;
  final String _authToken;

  final String baseUrl = 'https://paxtech.azurewebsites.net/api/v1/time-slots';

  static const String _defaultToken =
      'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJjYXJvY2Fyb0BnbWFpbC5jb20iLCJpYXQiOjE3NjI5MDk5NjIsImV4cCI6MTc2MzUxNDc2Mn0.jr_CP1m6Z9Uj0-13okXMGLmTnbFIIJL06aSCRbHbQjN2tMSDTbz-Mr0b0XOZ0iJb';

  Map<String, String> get _headers => {
    HttpHeaders.authorizationHeader: 'Bearer $_authToken',
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  Future<List<TimeSlot>> getTimeSlots() async {
    // ... (tu código existente de getTimeSlots)
    final response = await _client.get(Uri.parse(baseUrl), headers: _headers);
    if (response.statusCode == HttpStatus.ok) {
      List list = jsonDecode(response.body);
      return list
          .map((json) => TimeSlot.fromJson(json))
          .where((slot) => slot.status == true)
          .toList();
    } else {
      throw HttpException(
        'Failed to load time slots. Status code: ${response.statusCode}',
        uri: Uri.parse(baseUrl),
      );
    }
  }

  // --- ¡AÑADE ESTE NUEVO MÉTODO! ---
  Future<TimeSlot> createTimeSlot(TimeSlotRequest request) async {
    final uri = Uri.parse(baseUrl);
    final body = jsonEncode(request.toJson());

    final response = await _client.post(uri, headers: _headers, body: body);

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      // El API devuelve el TimeSlot recién creado
      return TimeSlot.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw HttpException(
        'Failed to create time slot. Status code: ${response.statusCode}',
        uri: uri,
      );
    }
  }
}