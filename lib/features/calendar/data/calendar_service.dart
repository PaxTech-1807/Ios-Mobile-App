// features/calendar/data/calendar_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation_request.dart';

class CalendarService {
  // Constructor para aceptar el token
  CalendarService({http.Client? client, String? authToken})
      : _client = client ?? http.Client(),
        _authToken = authToken ?? _defaultToken;

  final http.Client _client;
  final String _authToken;

  final String baseUrl =
      'https://paxtech.azurewebsites.net/api/v1/reservationsDetails';

  // Token de fallback (el de carocaro@gmail.com)
  static const String _defaultToken =
      'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJjYXJvY2Fyb0BnbWFpbC5jb20iLCJpYXQiOjE3NjI5MDk5NjIsImV4cCI6MTc2MzUxNDc2Mn0.jr_CP1m6Z9Uj0-13okXMGLmTnbFIIJL06aSCRbHbQjN2tMSDTbz-Mr0b0XOZ0iJb';

  Map<String, String> get _headers => {
    HttpHeaders.authorizationHeader: 'Bearer $_authToken',
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  Future<List<Reservation>> getReservations() async {
    final response =
    await _client.get(Uri.parse('$baseUrl/details'), headers: _headers);

    if (response.statusCode == HttpStatus.ok) {
      List reservations = jsonDecode(response.body);
      return reservations.map((json) => Reservation.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<Reservation> getReservationDetails(int reservationId) async {
    // --- ¡AQUÍ ESTÁ LA CORRECCIÓN! ---
    // Agregamos la barra "/" al final
    final uri = Uri.parse('$baseUrl/details/$reservationId/');

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == HttpStatus.ok) {
      return Reservation.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      print('Error al getReservationDetails: ${response.statusCode}');
      print('Cuerpo: ${response.body}');
      throw HttpException(
        'Failed to get reservation details. Status code: ${response.statusCode}',
        uri: uri,
      );
    }
  }

  Future<Reservation> createReservation(ReservationRequest request) async {
    final uri = Uri.parse(baseUrl);
    final body = jsonEncode(request.toJson());

    final response = await _client.post(uri, headers: _headers, body: body);

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      final minimalResponse =
      jsonDecode(response.body) as Map<String, dynamic>;
      final newId = minimalResponse['id'] as int;

      // Ahora esta llamada debería funcionar
      return await getReservationDetails(newId);
    } else {
      print('Error al crear reserva: ${response.statusCode}');
      print('Cuerpo: ${response.body}');
      throw HttpException(
        'Failed to create reservation. Status code: ${response.statusCode}',
        uri: uri,
      );
    }
  }
}