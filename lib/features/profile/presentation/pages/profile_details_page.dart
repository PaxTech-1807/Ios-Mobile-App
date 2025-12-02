import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/onboarding_service.dart';
import '../../data/geocoding_service.dart';
import '../../data/providerProfile_service.dart';
import '../../domain/providerProfile.dart';
import 'location_edit_page.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final _onboardingService = OnboardingService();
  final _profileService = ProviderprofileService();
  final _geocodingService = GeocodingService();
  String? _companyName;
  ProviderProfile? _profile;
  String? _locationAddress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    print('🔄 [ProfileDetailsPage] Iniciando carga de perfil...');
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('📝 [ProfileDetailsPage] Obteniendo nombre de empresa...');
      final companyName = await _onboardingService.getCompanyName();
      print('✅ [ProfileDetailsPage] Nombre de empresa: $companyName');
      
      print('👤 [ProfileDetailsPage] Obteniendo perfil completo...');
      final profile = await _profileService.getCurrentProfile();
      print('✅ [ProfileDetailsPage] Perfil obtenido: providerId=${profile.providerId}, location="${profile.location}"');

      // Si la ubicación tiene formato lat,long, convertirla a dirección legible
      String? locationAddress;
      if (profile.location.isNotEmpty && profile.location.contains(',')) {
        try {
          final parts = profile.location.split(',');
          if (parts.length == 2) {
            final lat = double.parse(parts[0].trim());
            final lon = double.parse(parts[1].trim());
            
            print('🗺️ [ProfileDetailsPage] Convirtiendo coordenadas a dirección...');
            locationAddress = await _geocodingService.reverseGeocode(lat, lon);
            print('✅ [ProfileDetailsPage] Dirección obtenida: $locationAddress');
          }
        } catch (e) {
          print('⚠️ [ProfileDetailsPage] Error al convertir coordenadas: $e');
          // Si falla, usar las coordenadas como están
        }
      }

      if (mounted) {
        setState(() {
          _companyName = companyName;
          _profile = profile;
          _locationAddress = locationAddress;
          _isLoading = false;
        });
        print('✅ [ProfileDetailsPage] Estado actualizado correctamente');
      }
    } catch (e) {
      print('❌ [ProfileDetailsPage] Error al cargar perfil: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateLocation(String newLocation) async {
    print('📍 [ProfileDetailsPage] Iniciando actualización de ubicación a: "$newLocation"');
    
    try {
      final updatedProfile = await _profileService.updateProfileLocation(
        location: newLocation,
      );
      
      print('✅ [ProfileDetailsPage] Ubicación actualizada correctamente');

      // Convertir las coordenadas a dirección legible
      String? locationAddress;
      if (newLocation.contains(',')) {
        try {
          final parts = newLocation.split(',');
          if (parts.length == 2) {
            final lat = double.parse(parts[0].trim());
            final lon = double.parse(parts[1].trim());
            
            print('🗺️ [ProfileDetailsPage] Convirtiendo nuevas coordenadas a dirección...');
            locationAddress = await _geocodingService.reverseGeocode(lat, lon);
            print('✅ [ProfileDetailsPage] Nueva dirección: $locationAddress');
          }
        } catch (e) {
          print('⚠️ [ProfileDetailsPage] Error al convertir coordenadas: $e');
        }
      }

      if (mounted) {
        setState(() {
          _profile = updatedProfile;
          _locationAddress = locationAddress;
        });
        print('✅ [ProfileDetailsPage] Estado actualizado con nueva ubicación');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ [ProfileDetailsPage] Error al actualizar ubicación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar ubicación: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Future<void> _uploadProfileImage() async {
    if (_profile == null) return;

    print('📸 [ProfileDetailsPage] Iniciando selección de imagen...');

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        print('⚠️ [ProfileDetailsPage] Usuario canceló selección de imagen');
        return;
      }

      print('📁 [ProfileDetailsPage] Imagen seleccionada: ${image.path}');

      // Mostrar loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF7209B7),
            ),
          ),
        );
      }

      // Subir imagen (XFile funciona en web y móvil)
      final updatedProfile = await _profileService.uploadProfileImage(
        imageFile: image,
        profileId: _profile!.id,
      );

      print('✅ [ProfileDetailsPage] Imagen subida exitosamente');

      if (mounted) {
        Navigator.pop(context); // Cerrar loading dialog

        setState(() {
          _profile = updatedProfile;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen de perfil actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ [ProfileDetailsPage] Error al subir imagen: $e');

      if (mounted) {
        // Intentar cerrar loading dialog si está abierto
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    }
    final first = parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
    final last = parts.last.isNotEmpty ? parts.last[0].toUpperCase() : '';
    final initials = '$first$last';
    return initials.isEmpty ? '?' : initials;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Perfil del negocio'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7209B7),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Perfil del negocio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileIdentityCard(
              companyName: _companyName,
              profile: _profile,
              getInitials: _getInitials,
              onImageTap: _uploadProfileImage,
            ),
            const SizedBox(height: 20),
            _InfoSectionCard(
              title: 'Información del negocio',
              children: [
                _InfoRow(
                  icon: Icons.store_mall_directory_outlined,
                  label: 'Nombre de empresa',
                  value: _companyName ?? 'Mi Salón',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Número de celular',
                  value: '+51 987654321',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'Sobre nosotros',
              children: [
                _InfoRow(
                  label: 'Descripción',
                  value: 'Somos especialistas en cortes y tratamientos capilares personalizados para cada estilo.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'Horarios',
              children: [
                _InfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'Lun - Sáb',
                  value: '09:00 am — 08:00 pm',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Dom',
                  value: '10:00 am — 04:00 pm',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'Redes sociales',
              children: [
                _InfoRow(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  value: '@glowgo',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  value: '/glowgo',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoSectionCard(
              title: 'Ubicación',
              trailing: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7209B7),
                      Color(0xFF9D4EDD),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7209B7).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LocationEditPage(),
                        ),
                      ).then((_) {
                        // Recargar perfil después de editar
                        _loadProfile();
                      });
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              children: [
                _InfoRow(
                  icon: Icons.add_location_alt_outlined,
                  label: 'Dirección',
                  value: _profile?.location.isEmpty ?? true
                      ? 'No configurada'
                      : _locationAddress ?? _profile!.location,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
    required this.companyName,
    required this.profile,
    required this.getInitials,
    required this.onImageTap,
  });

  final String? companyName;
  final ProviderProfile? profile;
  final String Function(String?) getInitials;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7209B7),
            Color(0xFF9D4EDD),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7209B7).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    image: profile?.profileImageUrl != null &&
                            profile!.profileImageUrl != 'to Choose' &&
                            profile!.profileImageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profile!.profileImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profile?.profileImageUrl == null ||
                          profile!.profileImageUrl == 'to Choose' ||
                          profile!.profileImageUrl!.isEmpty
                      ? Center(
                          child: Text(
                            getInitials(companyName),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                // Icono de cámara en la esquina
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7209B7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName ?? 'Mi Salón',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Salón de belleza y barbería especializada.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7209B7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF7209B7),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}