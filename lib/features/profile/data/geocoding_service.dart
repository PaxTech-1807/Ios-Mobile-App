import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LocationSuggestion {
  final String displayName;
  final double lat;
  final double lon;
  final String address;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.address,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] as String? ?? '',
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
      address: json['display_name'] as String? ?? '',
    );
  }

  /// Retorna el formato lat,long para guardar en la base de datos
  String get latLongString => '$lat,$lon';
}

class GeocodingService {
  static const String _nominatimBaseUrl =
      'https://nominatim.openstreetmap.org';

  /// Busca direcciones basadas en el query del usuario
  /// Retorna una lista de sugerencias
  Future<List<LocationSuggestion>> searchAddresses(String query) async {
    if (query.isEmpty || query.length < 3) {
      return [];
    }

    try {
      print('🔍 [GeocodingService] Buscando: "$query"');

      final uri = Uri.parse('$_nominatimBaseUrl/search').replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': '5',
          'countrycodes': 'pe', // Perú - cambia según tu país
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'IosMobileApp/1.0', // Nominatim requiere User-Agent
        },
      );

      print('📊 [GeocodingService] Status: ${response.statusCode}');

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        final suggestions = jsonList
            .map((json) => LocationSuggestion.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ [GeocodingService] ${suggestions.length} resultados encontrados');
        return suggestions;
      }

      print('❌ [GeocodingService] Error: ${response.statusCode}');
      return [];
    } catch (e) {
      print('💥 [GeocodingService] Exception: $e');
      return [];
    }
  }

  /// Convierte coordenadas lat,long a dirección legible
  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      print('🗺️ [GeocodingService] Reverse geocoding: $lat,$lon');

      final uri = Uri.parse('$_nominatimBaseUrl/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'IosMobileApp/1.0',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final address = json['display_name'] as String?;
        print('✅ [GeocodingService] Dirección encontrada: $address');
        return address;
      }

      return null;
    } catch (e) {
      print('💥 [GeocodingService] Exception en reverseGeocode: $e');
      return null;
    }
  }
}


