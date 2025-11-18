import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/service/domain/service.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_bloc.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_event.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_state.dart';

class ServiceFormPage extends StatefulWidget {
  const ServiceFormPage({super.key, this.initialService});

  final Service? initialService;

  bool get isEditing => initialService != null;

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialService?.name ?? '',
    );
    _durationController = TextEditingController(
      text: widget.initialService != null
          ? widget.initialService!.duration.toString()
          : '',
    );
    _priceController = TextEditingController(
      text: widget.initialService != null
          ? widget.initialService!.price.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicesBloc, ServicesState>(
      listenWhen: (previous, current) =>
          previous.formStatus != current.formStatus,
      listener: (context, state) {
        switch (state.formStatus) {
          case ServiceFormStatus.success:
            context.read<ServicesBloc>().add(const ServiceFormReset());
            Navigator.of(context).pop(true);
            break;
          case ServiceFormStatus.failure:
            final message =
                state.formErrorMessage ?? 'Ocurrió un error al guardar.';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            break;
          case ServiceFormStatus.idle:
          case ServiceFormStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Editar servicio' : 'Nuevo servicio',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Section
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7209B7),
                            Color(0xFF9D4EDD),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.content_cut,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Nombre del servicio
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nombre del servicio',
                    hintText: 'Ej. Corte simple',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Duración y Precio en Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _durationController,
                          label: 'Duración (min)',
                          hintText: 'Ej. 30',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La duración es obligatoria.';
                            }
                            final parsed = int.tryParse(value);
                            if (parsed == null || parsed <= 0) {
                              return 'Ingresa una duración válida.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          label: 'Precio',
                          hintText: 'Ej. 35.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El precio es obligatorio.';
                            }
                            final parsed = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (parsed == null || parsed < 0) {
                              return 'Ingresa un precio válido.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Botones
                  BlocBuilder<ServicesBloc, ServicesState>(
                    builder: (context, state) {
                      final isSubmitting =
                          state.formStatus == ServiceFormStatus.submitting;
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
                                        ? 'Guardar cambios'
                                        : 'Guardar servicio',
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

    final duration = int.parse(_durationController.text.trim());
    final price = double.parse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    final providerId = widget.initialService?.providerId ?? 1;

    final request = ServiceRequest(
      name: _nameController.text.trim(),
      duration: duration,
      price: price,
      status: widget.initialService?.status,
      providerId: providerId,
    );

    final bloc = context.read<ServicesBloc>();
    if (widget.isEditing) {
      bloc.add(
        UpdateServiceRequested(
          serviceId: widget.initialService!.id,
          request: request,
        ),
      );
    } else {
      bloc.add(CreateServiceRequested(request: request));
    }
  }
}
