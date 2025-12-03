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

  Future<void> _showEditSocialsDialog() async {
    if (_profile == null) return;

    final instagramController = TextEditingController(
      text: _profile!.socials?.additionalProp1 ?? '',
    );
    final facebookController = TextEditingController(
      text: _profile!.socials?.additionalProp2 ?? '',
    );
    final otherController = TextEditingController(
      text: _profile!.socials?.additionalProp3 ?? '',
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Editar redes sociales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: instagramController,
                decoration: InputDecoration(
                  labelText: 'Instagram',
                  hintText: '@usuario',
                  prefixIcon: const Icon(Icons.camera_alt_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: facebookController,
                decoration: InputDecoration(
                  labelText: 'Facebook',
                  hintText: '/pagina',
                  prefixIcon: const Icon(Icons.facebook),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otherController,
                decoration: InputDecoration(
                  labelText: 'Otra red social',
                  hintText: 'URL o usuario',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop({
                'instagram': instagramController.text.trim(),
                'facebook': facebookController.text.trim(),
                'other': otherController.text.trim(),
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7209B7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && _profile != null) {
      try {
        // Crear nuevo objeto ProfileSocials
        final newSocials = ProfileSocials(
          additionalProp1: result['instagram']!.isEmpty ? null : result['instagram'],
          additionalProp2: result['facebook']!.isEmpty ? null : result['facebook'],
          additionalProp3: result['other']!.isEmpty ? null : result['other'],
        );

        // Actualizar perfil con nuevas redes sociales
        final updatedProfile = _profile!.copyWith(socials: newSocials);
        final savedProfile = await _profileService.updateProfile(updatedProfile);

        if (mounted) {
          setState(() {
            _profile = savedProfile;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redes sociales actualizadas exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar redes sociales: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatSchedule() {
    if (_profile?.openTime == null || _profile?.closeTime == null) {
      return 'No configurado';
    }
    return '${_profile!.openTime} — ${_profile!.closeTime}';
  }

  Future<void> _showEditDescriptionDialog() async {
    if (_profile == null) return;

    final descriptionController = TextEditingController(
      text: _profile!.description ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: const Text(
          'Editar descripción',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Describe tu negocio...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 5,
                  autofocus: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(descriptionController.text.trim());
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7209B7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && _profile != null) {
      try {
        final updatedProfile = _profile!.copyWith(description: result.isEmpty ? null : result);
        final savedProfile = await _profileService.updateProfile(updatedProfile);

        if (mounted) {
          setState(() {
            _profile = savedProfile;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Descripción actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar descripción: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditScheduleDialog() async {
    if (_profile == null) return;

    // Crear lista de horas de 00:00 a 24:00
    final List<String> hours =
        List<String>.generate(25, (index) => index.toString().padLeft(2, '0') + ':00');

    // Posiciones iniciales según el perfil actual
    int initialOpenIndex = 9; // 09:00 por defecto
    int initialCloseIndex = 20; // 20:00 por defecto

    if (_profile?.openTime != null) {
      final open = _profile!.openTime!;
      final hour = int.tryParse(open.split(':').first) ?? 9;
      if (hour >= 0 && hour <= 24) {
        initialOpenIndex = hour;
      }
    }

    if (_profile?.closeTime != null) {
      final close = _profile!.closeTime!;
      final hour = int.tryParse(close.split(':').first) ?? 20;
      if (hour >= 0 && hour <= 24) {
        initialCloseIndex = hour;
      }
    }

    int selectedOpenIndex = initialOpenIndex;
    int selectedCloseIndex = initialCloseIndex;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: const Text(
          'Editar horarios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Selecciona horario de apertura y cierre',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8, bottom: 4),
                            child: Text(
                              'Apertura',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: StatefulBuilder(
                              builder: (context, setInnerState) {
                                return ListWheelScrollView.useDelegate(
                                  itemExtent: 36,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setInnerState(() {
                                      selectedOpenIndex = index;
                                    });
                                  },
                                  controller: FixedExtentScrollController(
                                    initialItem: initialOpenIndex,
                                  ),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      if (index < 0 || index >= hours.length) {
                                        return null;
                                      }
                                      final isSelected = index == selectedOpenIndex;
                                      return Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 150),
                                          style: TextStyle(
                                            fontSize: isSelected ? 16 : 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? const Color(0xFF7209B7)
                                                : Colors.grey.shade700,
                                          ),
                                          child: Text(hours[index]),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8, bottom: 4),
                            child: Text(
                              'Cierre',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: StatefulBuilder(
                              builder: (context, setInnerState) {
                                return ListWheelScrollView.useDelegate(
                                  itemExtent: 36,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setInnerState(() {
                                      selectedCloseIndex = index;
                                    });
                                  },
                                  controller: FixedExtentScrollController(
                                    initialItem: initialCloseIndex,
                                  ),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      if (index < 0 || index >= hours.length) {
                                        return null;
                                      }
                                      final isSelected = index == selectedCloseIndex;
                                      return Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 150),
                                          style: TextStyle(
                                            fontSize: isSelected ? 16 : 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? const Color(0xFF7209B7)
                                                : Colors.grey.shade700,
                                          ),
                                          child: Text(hours[index]),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop({
                'openTime': hours[selectedOpenIndex],
                'closeTime': hours[selectedCloseIndex],
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7209B7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && _profile != null) {
      try {
        final updatedProfile = _profile!.copyWith(
          openTime: result['openTime']!.isEmpty ? null : result['openTime'],
          closeTime: result['closeTime']!.isEmpty ? null : result['closeTime'],
        );
        final savedProfile = await _profileService.updateProfile(updatedProfile);

        if (mounted) {
          setState(() {
            _profile = savedProfile;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Horarios actualizados exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar horarios: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileIdentityCard(
                  companyName: _companyName,
                  profile: _profile,
                  getInitials: _getInitials,
                  onImageTap: _uploadProfileImage,
                  isLoading: _isLoading,
                ),
            const SizedBox(height: 20),
            _InfoSectionCard(
              title: 'Información del negocio',
              children: [
                _InfoRow(
                  icon: Icons.store_mall_directory_outlined,
                  label: 'Nombre de empresa',
                  value: _companyName ?? 'Mi salón',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Correo electrónico',
                  value: _profile?.email ?? 'No configurado',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'Sobre nosotros',
              trailing: GestureDetector(
                onTap: () => _showEditDescriptionDialog(),
                child: Container(
                  padding: const EdgeInsets.all(8),
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
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              children: [
                _InfoRow(
                  label: 'Descripción',
                  value: _profile?.description?.isNotEmpty ?? false
                      ? _profile!.description!
                      : 'No configurado',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'Horarios',
              trailing: GestureDetector(
                onTap: () => _showEditScheduleDialog(),
                child: Container(
                  padding: const EdgeInsets.all(8),
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
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              children: [
                _InfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'Horario',
                  value: _formatSchedule(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'Redes sociales',
              trailing: GestureDetector(
                onTap: () => _showEditSocialsDialog(),
                child: Container(
                  padding: const EdgeInsets.all(8),
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
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              children: [
                _InfoRow(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  value: _profile?.socials?.additionalProp1 ?? 'No configurado',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  value: _profile?.socials?.additionalProp2 ?? 'No configurado',
                ),
                if (_profile?.socials?.additionalProp3 != null &&
                    _profile!.socials!.additionalProp3!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.link,
                    label: 'Otra red social',
                    value: _profile!.socials!.additionalProp3!,
                  ),
                ],
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
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7209B7),
                ),
              ),
            ),
        ],
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
    this.isLoading = false,
  });

  final String? companyName;
  final ProviderProfile? profile;
  final String Function(String?) getInitials;
  final VoidCallback onImageTap;
  final bool isLoading;

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
                  companyName ?? 'Mi salón',
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