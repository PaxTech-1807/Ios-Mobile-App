import 'package:flutter/material.dart';
import '../../data/geocoding_service.dart';
import '../../data/location_service.dart';
import '../../data/providerProfile_service.dart';
import '../../domain/providerProfile.dart';

class LocationEditPage extends StatefulWidget {
  const LocationEditPage({super.key});

  @override
  State<LocationEditPage> createState() => _LocationEditPageState();
}

class _LocationEditPageState extends State<LocationEditPage> {
  final _profileService = ProviderprofileService();
  final _geocodingService = GeocodingService();
  String? _locationAddress;
  String? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _profileService.getCurrentProfile();
      _currentLocation = profile.location;

      // Convertir coordenadas a dirección legible si existe
      if (_currentLocation != null && _currentLocation!.isNotEmpty && _currentLocation!.contains(',')) {
        try {
          final parts = _currentLocation!.split(',');
          if (parts.length == 2) {
            final lat = double.parse(parts[0].trim());
            final lon = double.parse(parts[1].trim());
            
            _locationAddress = await _geocodingService.reverseGeocode(lat, lon);
          }
        } catch (e) {
          print('⚠️ [LocationEditPage] Error al convertir coordenadas: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar ubicación: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => _LocationSearchScreen(
          initialLocation: _currentLocation,
        ),
      ),
    );

    if (result != null && result.isNotEmpty && result != _currentLocation) {
      await _updateLocation(result);
    }
  }

  Future<void> _updateLocation(String newLocation) async {
    try {
      final updatedProfile = await _profileService.updateProfileLocation(
        location: newLocation,
      );
      
      // Convertir las coordenadas a dirección legible
      String? locationAddress;
      if (newLocation.contains(',')) {
        try {
          final parts = newLocation.split(',');
          if (parts.length == 2) {
            final lat = double.parse(parts[0].trim());
            final lon = double.parse(parts[1].trim());
            
            locationAddress = await _geocodingService.reverseGeocode(lat, lon);
          }
        } catch (e) {
          print('⚠️ [LocationEditPage] Error al convertir coordenadas: $e');
        }
      }

      if (mounted) {
        setState(() {
          _currentLocation = newLocation;
          _locationAddress = locationAddress;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Editar ubicación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7209B7),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7209B7).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Color(0xFF7209B7),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ubicación actual',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _locationAddress ?? 
                                        (_currentLocation?.isNotEmpty ?? false
                                            ? _currentLocation!
                                            : 'No configurada'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF7209B7),
                                Color(0xFF9D4EDD),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7209B7).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _selectLocation,
                              borderRadius: BorderRadius.circular(14),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Cambiar ubicación',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LocationSearchScreen extends StatefulWidget {
  final String? initialLocation;

  const _LocationSearchScreen({this.initialLocation});

  @override
  State<_LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<_LocationSearchScreen> {
  final _searchController = TextEditingController();
  final _geocodingService = GeocodingService();
  final _locationService = LocationService();

  List<LocationSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _isLoadingCurrentLocation = false;
  bool _isValidating = false;
  String? _selectedLatLong;
  String? _selectedAddress;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null && widget.initialLocation!.isNotEmpty) {
      _parseInitialLocation();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _parseInitialLocation() async {
    final location = widget.initialLocation!;
    if (location.contains(',')) {
      try {
        final parts = location.split(',');
        if (parts.length == 2) {
          final lat = double.parse(parts[0].trim());
          final lon = double.parse(parts[1].trim());
          
          _selectedLatLong = location;
          
          final address = await _geocodingService.reverseGeocode(lat, lon);
          if (address != null && mounted) {
            setState(() {
              _selectedAddress = address;
              _searchController.text = address;
            });
          }
        }
      } catch (e) {
        print('Error parsing location: $e');
      }
    } else {
      _searchController.text = location;
      _selectedAddress = location;
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _geocodingService.searchAddresses(query);

    if (mounted) {
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();

      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener la ubicación actual'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final address = await _geocodingService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _selectedLatLong = '${position.latitude},${position.longitude}';
          _selectedAddress = address ?? 'Ubicación actual';
          _searchController.text = _selectedAddress!;
          _suggestions = [];
          _isLoadingCurrentLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    setState(() {
      _selectedLatLong = suggestion.latLongString;
      _selectedAddress = suggestion.displayName;
      _searchController.text = suggestion.displayName;
      _suggestions = [];
      _validationError = null;
    });
  }

  Future<void> _validateAndSaveManualAddress() async {
    final address = _searchController.text.trim();
    
    if (address.isEmpty) {
      setState(() {
        _validationError = 'Por favor ingresa una dirección';
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    try {
      final latLong = await _geocodingService.validateAndGeocodeAddress(address);

      if (latLong != null) {
        final parts = latLong.split(',');
        if (parts.length == 2) {
          final lat = double.parse(parts[0].trim());
          final lon = double.parse(parts[1].trim());
          
          final verifiedAddress = await _geocodingService.reverseGeocode(lat, lon);
          
          if (mounted) {
            setState(() {
              _selectedLatLong = latLong;
              _selectedAddress = verifiedAddress ?? address;
              _searchController.text = verifiedAddress ?? address;
              _suggestions = [];
              _isValidating = false;
              _validationError = null;
            });
            
            Navigator.pop(context, latLong);
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isValidating = false;
            _validationError = 'No se pudo encontrar una ubicación válida para esta dirección. Por favor intenta con otra dirección o selecciona una de las sugerencias.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _validationError = 'Error al validar la dirección: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Seleccionar ubicación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar o escribir dirección',
                hintText: 'Ej: Av. Larco 1234, Miraflores',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                errorText: _validationError,
                errorMaxLines: 3,
              ),
              onChanged: (value) {
                _searchAddress(value);
                if (_validationError != null) {
                  setState(() {
                    _validationError = null;
                  });
                }
              },
              onSubmitted: (value) {
                if (_suggestions.isEmpty && value.trim().isNotEmpty) {
                  _validateAndSaveManualAddress();
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoadingCurrentLocation ? null : _useCurrentLocation,
              icon: _isLoadingCurrentLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.my_location, color: Colors.white),
              label: const Text('Usar mi ubicación actual', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7209B7),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_suggestions.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sugerencias:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Color(0xFF7209B7),
                              ),
                              title: Text(
                                suggestion.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () => _selectSuggestion(suggestion),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (_isValidating)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7209B7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF7209B7)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7209B7)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Validando dirección...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7209B7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (_selectedLatLong != null && _suggestions.isEmpty && !_isValidating)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ubicación seleccionada:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _selectedAddress ?? _selectedLatLong!,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isValidating
                  ? null
                  : (_selectedLatLong != null
                      ? () {
                          Navigator.pop(context, _selectedLatLong);
                        }
                      : (_searchController.text.trim().isNotEmpty
                          ? _validateAndSaveManualAddress
                          : null)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7209B7),
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isValidating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Guardar ubicación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

