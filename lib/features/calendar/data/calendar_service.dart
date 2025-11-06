import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';

class CalendarService {
  final String baseUrl = 'https://paxtech.azurewebsites.net/api/v1/reservationsDetails';

  Future<List<Reservation>> getReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/details'));

    if (response.statusCode == HttpStatus.ok) {
      List reservations  = jsonDecode(response.body);
      return reservations.map((json) => Reservation.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}