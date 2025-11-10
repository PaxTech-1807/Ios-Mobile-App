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
          title: Text(widget.isEditing ? 'Editar servicio' : 'Nuevo servicio'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _durationController,
                    label: 'Duración (minutos)',
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
                  const SizedBox(height: 16),
                  _buildTextField(
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
                  const SizedBox(height: 32),
                  BlocBuilder<ServicesBloc, ServicesState>(
                    builder: (context, state) {
                      final isSubmitting =
                          state.formStatus == ServiceFormStatus.submitting;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: isSubmitting ? null : _onSubmit,
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    widget.isEditing
                                        ? 'Guardar cambios'
                                        : 'Guardar servicio',
                                  ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
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
        border: const OutlineInputBorder(),
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
