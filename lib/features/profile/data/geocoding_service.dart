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

  /// Valida una dirección manual ingresada por el usuario
  /// Intenta convertirla a coordenadas y luego hacer reverse geocoding
  /// Retorna las coordenadas en formato "lat,long" si es válida, null si no
  Future<String?> validateAndGeocodeAddress(String address) async {
    if (address.trim().isEmpty) {
      return null;
    }

    try {
      print('🔍 [GeocodingService] Validando dirección manual: "$address"');

      // Primero intentar geocodificar la dirección (dirección -> coordenadas)
      final uri = Uri.parse('$_nominatimBaseUrl/search').replace(
        queryParameters: {
          'q': address,
          'format': 'json',
          'addressdetails': '1',
          'limit': '1',
          'countrycodes': 'pe',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'IosMobileApp/1.0',
        },
      );

      print('📊 [GeocodingService] Status: ${response.statusCode}');

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        
        if (jsonList.isEmpty) {
          print('❌ [GeocodingService] No se encontraron resultados para la dirección');
          return null;
        }

        final result = jsonList.first as Map<String, dynamic>;
        final lat = double.parse(result['lat'] as String);
        final lon = double.parse(result['lon'] as String);

        print('✅ [GeocodingService] Coordenadas encontradas: $lat,$lon');

        // Hacer reverse geocoding para verificar que las coordenadas son válidas
        final verifiedAddress = await reverseGeocode(lat, lon);
        
        if (verifiedAddress != null) {
          print('✅ [GeocodingService] Dirección validada: $verifiedAddress');
          return '$lat,$lon';
        } else {
          print('❌ [GeocodingService] No se pudo verificar la dirección');
          return null;
        }
      }

      print('❌ [GeocodingService] Error en la petición: ${response.statusCode}');
      return null;
    } catch (e) {
      print('💥 [GeocodingService] Exception en validateAndGeocodeAddress: $e');
      return null;
    }
  }
}



