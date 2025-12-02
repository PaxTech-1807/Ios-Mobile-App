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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            const Text(
              'Seleccionar Ubicación',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Campo de búsqueda
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
            const SizedBox(height: 12),

            // Botón de ubicación actual
            OutlinedButton.icon(
              onPressed: _isLoadingCurrentLocation ? null : _useCurrentLocation,
              icon: _isLoadingCurrentLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Usar mi ubicación actual'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7209B7),
                side: const BorderSide(color: Color(0xFF7209B7)),
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                          return ListTile(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Validando dirección...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Ubicación seleccionada
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

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isValidating ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isValidating
                      ? null
                      : (_selectedLatLong != null
                          ? () => Navigator.pop(context, _selectedLatLong)
                          : (_searchController.text.trim().isNotEmpty
                              ? _validateAndSaveManualAddress
                              : null)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7209B7),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isValidating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



