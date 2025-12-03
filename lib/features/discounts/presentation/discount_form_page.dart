import 'package:flutter/material.dart';
import '../domain/discount.dart';
import '../../../core/services/onboarding_service.dart';
import '../../profile/data/providerProfile_service.dart';

class DiscountFormPage extends StatefulWidget {
  const DiscountFormPage({super.key, this.discount});

  final Discount? discount;

  @override
  State<DiscountFormPage> createState() => _DiscountFormPageState();
}

class _DiscountFormPageState extends State<DiscountFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _contentController = TextEditingController();
  final _discountValueController = TextEditingController();
  
  int? _providerProfileId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProviderProfileId();
    if (widget.discount != null) {
      _titleController.text = widget.discount!.title;
      _subtitleController.text = widget.discount!.subtitle;
      _contentController.text = widget.discount!.content;
      _discountValueController.text = widget.discount!.discountValue.toStringAsFixed(0);
    }
  }

  Future<void> _loadProviderProfileId() async {
    try {
      // Usar la misma lógica que DiscountsService para obtener el providerProfileId
      // Obtener providerId primero
      final onboardingService = OnboardingService();
      final providerId = await onboardingService.getProviderId();
      if (providerId == null) {
        throw Exception(
          'Provider ID no encontrado. Por favor inicia sesión nuevamente.',
        );
      }
      
      // Buscar el ProviderProfile que tiene este providerId
      final profileService = ProviderprofileService();
      final profile = await profileService.getCurrentProfile();
      
      if (profile.id == null) {
        throw Exception(
          'El ProviderProfile no tiene un ID válido. Por favor contacta al soporte.',
        );
      }
      
      if (mounted) {
        setState(() {
          _providerProfileId = profile.id;
        });
      }
    } catch (e) {
      print('❌ [DiscountFormPage] Error obteniendo providerProfileId: $e');
      // No actualizar el estado si hay error, pero dejar que el usuario vea el error
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _providerProfileId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final discount = Discount(
      id: widget.discount?.id,
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      content: _contentController.text.trim(),
      discountType: 'PERCENTAGE',
      discountValue: double.parse(_discountValueController.text),
      providerProfileId: _providerProfileId!,
    );

    if (mounted) {
      Navigator.of(context).pop(discount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.discount == null ? 'Crear cupón' : 'Editar cupón',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Título',
                hint: 'Ej: Descuento de verano',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _subtitleController,
                label: 'Subtítulo',
                hint: 'Ej: Aprovecha esta oferta',
                icon: Icons.subtitles,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contentController,
                label: 'Descripción',
                hint: 'Detalles del cupón...',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _discountValueController,
                label: 'Porcentaje de descuento',
                hint: 'Ej: 20',
                icon: Icons.percent,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El porcentaje es requerido';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num <= 0 || num > 100) {
                    return 'Ingresa un porcentaje válido (1-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
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
                    onTap: _isLoading ? null : _save,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Guardar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
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
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF7209B7), size: 20),
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
          ),
        ),
      ],
    );
  }
}

