import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final TextEditingController _specializationController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _providerIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialWorker?.name ?? '',
    );
    _specializationController = TextEditingController(
      text: widget.initialWorker?.specialization ?? '',
    );
    _photoUrlController = TextEditingController(
      text: widget.initialWorker?.photoUrl ?? '',
    );
    _providerIdController = TextEditingController(
      text: widget.initialWorker?.providerId.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _photoUrlController.dispose();
    _providerIdController.dispose();
    super.dispose();
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
          title: Text(widget.isEditing ? 'Editar miembro' : 'Agregar miembro'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: _photoUrlController.text.isNotEmpty
                              ? NetworkImage(_photoUrlController.text)
                              : null,
                          child: _photoUrlController.text.isEmpty
                              ? const Icon(Icons.person, size: 48)
                              : null,
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Material(
                            elevation: 2,
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _promptPhotoUrl,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _specializationController,
                    label: 'Especialización',
                    hintText: 'Ej. Colorista, Barbería...',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La especialización es obligatoria.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _photoUrlController,
                    label: 'URL de la foto',
                    hintText: 'https://',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _providerIdController,
                    label: 'ID del proveedor',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El ID del proveedor es obligatorio.';
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null || parsed < 0) {
                        return 'Ingresa un número válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<WorkersBloc, WorkersState>(
                    builder: (context, state) {
                      final isSubmitting =
                          state.formStatus == WorkerFormStatus.submitting;
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
                                        ? 'Actualizar miembro'
                                        : 'Guardar miembro',
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

    final request = WorkerRequest(
      name: _nameController.text.trim(),
      specialization: _specializationController.text.trim(),
      photoUrl: _photoUrlController.text.trim(),
      providerId: int.parse(_providerIdController.text.trim()),
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
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
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
