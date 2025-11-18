import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/auth/data/auth_service.dart';
import 'package:iosmobileapp/features/team/domain/worker.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_bloc.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_event.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_state.dart';

class WorkerFormPage extends StatefulWidget {
  const WorkerFormPage({super.key, this.initialWorker});

  final Worker? initialWorker;

  bool get isEditing => initialWorker != null;

  @override
  State<WorkerFormPage> createState() => _WorkerFormPageState();
}

class _WorkerFormPageState extends State<WorkerFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _photoUrlController;
  
  final List<String> _availableSpecializations = [
    'Todos los servicios',
    'Corte',
    'Tinte',
    'Alisado',
    'Peinado',
    'Manicure',
    'Pedicure',
    'Maquillaje',
    'Depilación',
    'Tratamiento facial',
    'Barbería',
  ];
  
  final Set<String> _selectedSpecializations = {};
  int? _providerId;
  bool _isLoadingProviderId = true;
  final _onboardingService = OnboardingService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialWorker?.name ?? '',
    );
    _photoUrlController = TextEditingController(
      text: widget.initialWorker?.photoUrl ?? '',
    );
    
    // Inicializar especializaciones seleccionadas
    if (widget.initialWorker?.specialization.isNotEmpty == true) {
      final specializations = widget.initialWorker!.specialization
          .split(', ')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      _selectedSpecializations.addAll(specializations);
    }
    
    _loadProviderId();
  }

  Future<void> _loadProviderId() async {
    try {
      final userId = await _onboardingService.getUserId();
      if (userId != null) {
        final token = await _onboardingService.getJwtToken();
        if (token != null) {
          final provider = await _authService.getProviderByUserId(
            userId: userId,
            token: token,
          );
          if (mounted) {
            setState(() {
              _providerId = provider?.id ?? widget.initialWorker?.providerId;
              _isLoadingProviderId = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _providerId = widget.initialWorker?.providerId;
              _isLoadingProviderId = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _providerId = widget.initialWorker?.providerId;
            _isLoadingProviderId = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _providerId = widget.initialWorker?.providerId;
          _isLoadingProviderId = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  void _toggleSpecialization(String specialization) {
    setState(() {
      if (specialization == 'Todos los servicios') {
        // Si selecciona "Todos los servicios", limpiar todo y solo dejar esa
        _selectedSpecializations.clear();
        _selectedSpecializations.add('Todos los servicios');
      } else {
        // Si selecciona otra especialización, quitar "Todos los servicios"
        _selectedSpecializations.remove('Todos los servicios');
        
        if (_selectedSpecializations.contains(specialization)) {
          _selectedSpecializations.remove(specialization);
        } else {
          // Solo permitir hasta 3 especializaciones
          if (_selectedSpecializations.length < 3) {
            _selectedSpecializations.add(specialization);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Puedes seleccionar máximo 3 especializaciones'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkersBloc, WorkersState>(
      listenWhen: (previous, current) =>
          previous.formStatus != current.formStatus,
      listener: (context, state) {
        switch (state.formStatus) {
          case WorkerFormStatus.success:
            context.read<WorkersBloc>().add(const WorkerFormReset());
            Navigator.of(context).pop(true);
            break;
          case WorkerFormStatus.failure:
            final errorMessage =
                state.formErrorMessage ?? 'Ocurrió un error al guardar.';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
            break;
          case WorkerFormStatus.idle:
          case WorkerFormStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Editar trabajador' : 'Agregar trabajador',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        body: _isLoadingProviderId
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Section
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF7209B7),
                                      Color(0xFF9D4EDD),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _photoUrlController.text.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          _photoUrlController.text,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.white,
                                            );
                                          },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Material(
                                  elevation: 4,
                                  shape: const CircleBorder(),
                                  color: Colors.white,
                                  child: InkWell(
                                    onTap: _promptPhotoUrl,
                                    customBorder: const CircleBorder(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Color(0xFF7209B7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Nombre completo
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nombre completo',
                          hintText: 'Ej. Carlos Castillo',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El nombre es obligatorio.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Especializaciones
                        Text(
                          'Especializaciones',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecciona hasta 3 especializaciones',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableSpecializations.map((spec) {
                            final isSelected = _selectedSpecializations.contains(spec);
                            return FilterChip(
                              label: Text(spec),
                              selected: isSelected,
                              onSelected: (_) => _toggleSpecialization(spec),
                              selectedColor: const Color(0xFF7209B7).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF7209B7),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF7209B7)
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF7209B7)
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            );
                          }).toList(),
                        ),
                        if (_selectedSpecializations.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Debes seleccionar al menos una especialización',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        
                        // URL de la foto
                        _buildTextField(
                          controller: _photoUrlController,
                          label: 'URL de la foto (opcional)',
                          hintText: 'https://',
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 32),
                        
                        // Botones
                        BlocBuilder<WorkersBloc, WorkersState>(
                          builder: (context, state) {
                            final isSubmitting =
                                state.formStatus == WorkerFormStatus.submitting;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FilledButton(
                                  onPressed: isSubmitting ? null : _onSubmit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF7209B7),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          widget.isEditing
                                              ? 'Actualizar trabajador'
                                              : 'Guardar trabajador',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF7209B7),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar al menos una especialización'),
        ),
      );
      return;
    }

    if (_providerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener el ID del proveedor'),
        ),
      );
      return;
    }

    // Unir especializaciones con ", "
    final specialization = _selectedSpecializations.join(', ');

    // Si photoUrl está vacío, usar URL por defecto
    final photoUrlText = _photoUrlController.text.trim();
    const defaultPhotoUrl = 'https://example.com';
    final photoUrl = photoUrlText.isEmpty ? defaultPhotoUrl : photoUrlText;

    final request = WorkerRequest(
      name: _nameController.text.trim(),
      specialization: specialization,
      photoUrl: photoUrl,
      providerId: _providerId!,
    );

    if (widget.isEditing) {
      final workerId = widget.initialWorker!.id;
      context.read<WorkersBloc>().add(
        UpdateWorkerRequested(workerId: workerId, request: request),
      );
    } else {
      context.read<WorkersBloc>().add(CreateWorkerRequested(request: request));
    }
  }

  Future<void> _promptPhotoUrl() async {
    final controller = TextEditingController(text: _photoUrlController.text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar foto'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'URL de la foto',
            hintText: 'https://',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7209B7),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _photoUrlController.text = result;
      });
    }
  }
}
