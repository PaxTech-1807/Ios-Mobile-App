import 'package:flutter/material.dart';
import '../../data/geocoding_service.dart';
import '../../data/location_service.dart';

class LocationSearchDialog extends StatefulWidget {
  final String? initialLocation;

  const LocationSearchDialog({
    this.initialLocation,
    super.key,
  });

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
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
    // Si ya tiene formato lat,long, hacer reverse geocoding
    if (location.contains(',')) {
      try {
        final parts = location.split(',');
        if (parts.length == 2) {
          final lat = double.parse(parts[0].trim());
          final lon = double.parse(parts[1].trim());
          
          _selectedLatLong = location;
          
          // Obtener dirección legible
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
      // Si es una dirección, usarla directamente
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

      // Obtener dirección legible
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
      // Validar y geocodificar la dirección manual
      final latLong = await _geocodingService.validateAndGeocodeAddress(address);

      if (latLong != null) {
        // Obtener la dirección verificada
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
            
            // Guardar automáticamente si es válida
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título con estilo mejorado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7209B7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF7209B7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Seleccionar Ubicación',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo de búsqueda con estilo mejorado
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar o escribir dirección',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7209B7), size: 20),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7209B7)),
                            ),
                          ),
                        )
                      : null,
                  errorText: _validationError,
                  errorMaxLines: 3,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF7209B7),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              onChanged: (value) {
                _searchAddress(value);
                // Limpiar error cuando el usuario empiece a escribir
                if (_validationError != null) {
                  setState(() {
                    _validationError = null;
                  });
                }
              },
              onSubmitted: (value) {
                // Si el usuario presiona Enter y no hay sugerencias, intentar validar
                if (_suggestions.isEmpty && value.trim().isNotEmpty) {
                  _validateAndSaveManualAddress();
                }
              },
            ),
            ),
            const SizedBox(height: 12),

            // Botón de ubicación actual con estilo mejorado
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF7209B7).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoadingCurrentLocation ? null : _useCurrentLocation,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoadingCurrentLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7209B7)),
                                ),
                              )
                            : const Icon(
                                Icons.my_location,
                                color: Color(0xFF7209B7),
                                size: 20,
                              ),
                        const SizedBox(width: 8),
                        Text(
                          'Usar mi ubicación actual',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isLoadingCurrentLocation
                                ? Colors.grey
                                : const Color(0xFF7209B7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de sugerencias
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7209B7).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF7209B7),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                suggestion.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              onTap: () => _selectSuggestion(suggestion),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Loading de validación
            if (_isValidating)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7209B7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7209B7).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7209B7)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Validando dirección...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7209B7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Ubicación seleccionada
            if (_selectedLatLong != null && _suggestions.isEmpty && !_isValidating)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress ?? _selectedLatLong!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
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

            const SizedBox(height: 20),

            // Botones de acción con estilo mejorado
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isValidating ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: _isValidating ||
                            (_selectedLatLong == null &&
                                _searchController.text.trim().isEmpty)
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF7209B7),
                              Color(0xFF9D4EDD),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    color: _isValidating ||
                            (_selectedLatLong == null &&
                                _searchController.text.trim().isEmpty)
                        ? Colors.grey
                        : null,
                    boxShadow: _isValidating ||
                            (_selectedLatLong == null &&
                                _searchController.text.trim().isEmpty)
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF7209B7).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isValidating
                          ? null
                          : (_selectedLatLong != null
                              ? () => Navigator.pop(context, _selectedLatLong)
                              : (_searchController.text.trim().isNotEmpty
                                  ? _validateAndSaveManualAddress
                                  : null)),
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: _isValidating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Guardar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



