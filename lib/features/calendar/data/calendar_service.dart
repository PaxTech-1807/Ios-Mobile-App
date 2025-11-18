import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';

class CalendarService {
  CalendarService({http.Client? client})
      : _client = client ?? http.Client(),
        _onboardingService = OnboardingService();

  final http.Client _client;
  final OnboardingService _onboardingService;

  final String baseUrl = 'https://paxtech.azurewebsites.net/api/v1/reservationsDetails';

  Future<Map<String, String>> get _headers async {
    final token = await _onboardingService.getJwtToken();
    if (token == null || token.isEmpty) {
      throw HttpException(
        'No se encontró token de autenticación. Por favor inicia sesión nuevamente.',
        uri: Uri.parse(baseUrl),
      );
    }
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  Future<List<Reservation>> getReservations() async {
    final headers = await _headers;
    final response = await _client.get(
      Uri.parse('$baseUrl/details'),
      headers: headers,
    );

    if (response.statusCode == HttpStatus.ok) {
      List reservations = jsonDecode(response.body);
      return reservations.map((json) => Reservation.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}