import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Verifica si los permisos de ubicación están habilitados
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ [LocationService] Servicio de ubicación deshabilitado');
      return false;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ [LocationService] Permisos de ubicación denegados');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ [LocationService] Permisos denegados permanentemente');
      return false;
    }

    print('✅ [LocationService] Permisos de ubicación concedidos');
    return true;
  }

  /// Obtiene la ubicación actual del dispositivo
  /// Retorna las coordenadas en formato "lat,long"
  Future<String?> getCurrentLocation() async {
    try {
      print('📍 [LocationService] Obteniendo ubicación actual...');

      // Verificar permisos
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        throw Exception('No se tienen permisos de ubicación');
      }

      // Obtener posición actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLong = '${position.latitude},${position.longitude}';
      print('✅ [LocationService] Ubicación obtenida: $latLong');

      return latLong;
    } catch (e) {
      print('💥 [LocationService] Error al obtener ubicación: $e');
      return null;
    }
  }

  /// Obtiene la posición actual como objeto Position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('💥 [LocationService] Error: $e');
      return null;
    }
  }
}



