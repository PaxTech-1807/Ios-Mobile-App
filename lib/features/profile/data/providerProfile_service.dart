import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iosmobileapp/core/api_constants.dart';
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/profile/domain/providerProfile.dart';
import 'package:http/http.dart' as http;

class ProviderprofileService {
  final _onboardingService = OnboardingService();

  /// Obtiene los headers con autenticación
  Future<Map<String, String>> get _headers async {
    final token = await _onboardingService.getJwtToken();
    print(
      '🔑 [ProfileService] Token obtenido: ${token != null ? "✅ Existe" : "❌ No existe"}',
    );

    if (token == null || token.isEmpty) {
      throw HttpException(
        'No se encontró token de autenticación. Por favor inicia sesión nuevamente.',
        uri: Uri.parse(ApiConstants.providerProfileEndpoint),
      );
    }

    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  /// Obtiene el providerId desde SharedPreferences
  Future<int> _getProviderId() async {
    final providerId = await _onboardingService.getProviderId();
    print('🆔 [ProfileService] Provider ID obtenido: $providerId');

    if (providerId == null) {
      throw Exception(
        'Provider ID no encontrado. Por favor inicia sesión nuevamente.',
      );
    }
    return providerId;
  }

  Future<ProviderProfile> getProfile({required int providerId}) async {
    try {
      print(
        '📥 [ProfileService] Obteniendo perfil para providerId: $providerId',
      );

      final headers = await _headers;
      final Uri uri = Uri.parse(
        '${ApiConstants.providerProfileEndpoint}/$providerId',
      );

      print('🌐 [ProfileService] GET: $uri');

      final response = await http.get(uri, headers: headers);

      print('📊 [ProfileService] Status Code: ${response.statusCode}');
      print('📄 [ProfileService] Response: ${response.body}');

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body);
        print('✅ [ProfileService] Perfil cargado exitosamente');
        return ProviderProfile.fromJson(json);
      }

      print('❌ [ProfileService] Error HTTP: ${response.statusCode}');
      throw ('Unexpected error occurred: ${response.statusCode}');
    } catch (e) {
      print('💥 [ProfileService] Exception en getProfile: $e');
      throw ('Error fetching profile: $e');
    }
  }

  Future<ProviderProfile> updateProfile(ProviderProfile profile) async {
    try {
      print(
        '📤 [ProfileService] Actualizando perfil id: ${profile.id}, providerId: ${profile.providerId}',
      );

      final headers = await _headers;
      final Uri uri = Uri.parse(
        '${ApiConstants.providerProfileEndpoint}/${profile.id}',
      );

      final body = jsonEncode(profile.toUpdateJson());
      print('🌐 [ProfileService] PUT: $uri');
      print('📝 [ProfileService] Body: $body');

      final response = await http.put(uri, headers: headers, body: body);

      print('📊 [ProfileService] Status Code: ${response.statusCode}');
      print('📄 [ProfileService] Response: ${response.body}');

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body);
        print('✅ [ProfileService] Perfil actualizado exitosamente');
        return ProviderProfile.fromJson(json);
      }

      print('❌ [ProfileService] Error HTTP: ${response.statusCode}');
      throw ('Unexpected error occurred: ${response.statusCode}');
    } catch (e) {
      print('💥 [ProfileService] Exception en updateProfile: $e');
      throw ('Error updating profile: $e');
    }
  }

  /// Actualiza solo la ubicación del perfil del proveedor actual
  Future<ProviderProfile> updateProfileLocation({
    required String location,
  }) async {
    try {
      print('📍 [ProfileService] Actualizando ubicación a: "$location"');

      // 1. Obtener el perfil actual del proveedor logueado
      print('⏳ [ProfileService] Paso 1/3: Obteniendo perfil actual...');
      final currentProfile = await getCurrentProfile();

      // 2. Crear una copia del perfil con la ubicación actualizada
      print(
        '⏳ [ProfileService] Paso 2/3: Creando copia con nueva ubicación...',
      );
      final updatedProfile = currentProfile.copyWith(location: location);

      // 3. Actualizar el perfil completo con el PUT
      print('⏳ [ProfileService] Paso 3/3: Guardando cambios...');
      final result = await updateProfile(updatedProfile);

      print('✅ [ProfileService] Ubicación actualizada exitosamente');
      return result;
    } catch (e) {
      print('💥 [ProfileService] Error en updateProfileLocation: $e');
      throw ('Error updating profile location: $e');
    }
  }

  /// Obtiene el perfil del proveedor actual logueado usando el endpoint directo
  Future<ProviderProfile> getCurrentProfile() async {
    try {
      print('👤 [ProfileService] Obteniendo perfil del usuario actual...');
      final providerId = await _getProviderId();

      print('🔍 [ProfileService] Buscando profile con providerId: $providerId');

      // Usar el nuevo endpoint que busca directamente por providerId
      final headers = await _headers;
      final Uri uri = Uri.parse(
        '${ApiConstants.providerProfileEndpoint}/provider/$providerId',
      );

      print('🌐 [ProfileService] GET: $uri');

      final response = await http.get(uri, headers: headers);

      print('📊 [ProfileService] Status Code: ${response.statusCode}');
      print('📄 [ProfileService] Response: ${response.body}');

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final profile = ProviderProfile.fromJson(json);

        print(
          '✅ [ProfileService] Perfil encontrado: id=${profile.id}, providerId=${profile.providerId}',
        );
        return profile;
      }

      if (response.statusCode == HttpStatus.notFound) {
        throw Exception(
          'No se encontró un perfil para el providerId: $providerId. '
          'Puede que necesites crear un perfil primero.',
        );
      }

      throw HttpException(
        'Error al obtener perfil. Status code: ${response.statusCode}',
        uri: uri,
      );
    } catch (e) {
      print('💥 [ProfileService] Error en getCurrentProfile: $e');
      rethrow;
    }
  }

  /// Sube una imagen de perfil al servidor
  /// Retorna el perfil actualizado con la nueva URL de la imagen
  /// Acepta XFile para compatibilidad con Web y móvil
  Future<ProviderProfile> uploadProfileImage({
    required XFile imageFile,
    required int profileId,
  }) async {
    try {
      print(
        '📤 [ProfileService] Subiendo imagen de perfil para profile ID: $profileId',
      );

      // Leer bytes del archivo (funciona en web y móvil)
      final bytes = await imageFile.readAsBytes();
      final fileSize = bytes.length;
      final fileSizeMB = fileSize / (1024 * 1024);
      print(
        '📏 [ProfileService] Tamaño del archivo: ${fileSizeMB.toStringAsFixed(2)} MB',
      );

      if (fileSize > 5 * 1024 * 1024) {
        throw Exception(
          'La imagen es demasiado grande. Tamaño máximo: 5MB. '
          'Tamaño actual: ${fileSizeMB.toStringAsFixed(2)} MB',
        );
      }

      final token = await _onboardingService.getJwtToken();
      if (token == null || token.isEmpty) {
        throw HttpException(
          'No se encontró token de autenticación.',
          uri: Uri.parse(ApiConstants.providerProfileEndpoint),
        );
      }

      final uri = Uri.parse(
        '${ApiConstants.providerProfileEndpoint}/$profileId/profile-image',
      );

      print('🌐 [ProfileService] POST: $uri');

      var request = http.MultipartRequest('POST', uri);

      // Agregar headers de autenticación
      request.headers['Authorization'] = 'Bearer $token';

      // Detectar el tipo MIME del archivo
      String mimeType = imageFile.mimeType ?? 'image/jpeg';
      print(
        '📎 [ProfileService] Tipo de archivo: $mimeType, nombre: ${imageFile.name}',
      );

      // Agregar la imagen usando bytes (compatible con web y móvil)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // nombre del campo esperado por el backend
          bytes,
          filename: imageFile.name,
          contentType: MediaType.parse(mimeType),
        ),
      );

      print('⏳ [ProfileService] Enviando imagen...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 [ProfileService] Status Code: ${response.statusCode}');
      print('📄 [ProfileService] Response: ${response.body}');

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final updatedProfile = ProviderProfile.fromJson(json);

        print('✅ [ProfileService] Imagen subida exitosamente');
        print(
          '🖼️ [ProfileService] Nueva URL: ${updatedProfile.profileImageUrl}',
        );

        return updatedProfile;
      }

      throw HttpException(
        'Error al subir imagen. Status code: ${response.statusCode}',
        uri: uri,
      );
    } catch (e) {
      print('💥 [ProfileService] Error en uploadProfileImage: $e');
      rethrow;
    }
  }
}
