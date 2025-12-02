import 'package:flutter/material.dart';
import '../data/discounts_service.dart';
import '../domain/discount.dart';
import 'widgets/discount_modal.dart';
import 'widgets/discount_card.dart';
import 'discount_form_page.dart';

class DiscountsPage extends StatefulWidget {
  const DiscountsPage({super.key});

  @override
  State<DiscountsPage> createState() => _DiscountsPageState();
}

class _DiscountsPageState extends State<DiscountsPage> {
  final _discountsService = DiscountsService();
  List<Discount> _discounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiscounts(); // Cargar automáticamente al entrar
  }

  Future<void> _loadDiscounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final discounts = await _discountsService.getDiscounts();
      if (mounted) {
        setState(() {
          _discounts = discounts;
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
            content: Text('Error al cargar cupones: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createDiscount() async {
    final result = await Navigator.of(context).push<Discount>(
      MaterialPageRoute(
        builder: (context) => const DiscountFormPage(),
      ),
    );

    if (result != null) {
      try {
        await _discountsService.createDiscount(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cupón creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadDiscounts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear cupón: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDiscountModal(Discount discount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DiscountModal(
        discount: discount,
        onEdit: () {
          Navigator.of(context).pop();
          _editDiscount(discount);
        },
        onDelete: () {
          Navigator.of(context).pop();
          _deleteDiscount(discount);
        },
        isDeleting: false,
      ),
    );
  }

  Future<void> _editDiscount(Discount discount) async {
    final result = await Navigator.of(context).push<Discount>(
      MaterialPageRoute(
        builder: (context) => DiscountFormPage(discount: discount),
      ),
    );

    if (result != null) {
      try {
        await _discountsService.updateDiscount(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cupón actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadDiscounts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar cupón: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteDiscount(Discount discount) async {
    if (discount.id == null) return;

    try {
      await _discountsService.deleteDiscount(discount.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cupón eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadDiscounts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar cupón: ${e.toString()}'),
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
          'Cupones de descuento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDiscounts,
        color: const Color(0xFF7209B7),
        child: _isLoading && _discounts.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7209B7),
                ),
              )
            : _discounts.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay descuentos registrados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _discounts.length,
                    itemBuilder: (context, index) {
                      final discount = _discounts[index];
                      return DiscountCard(
                        discount: discount,
                        onEdit: () => _editDiscount(discount),
                        onDelete: () => _deleteDiscount(discount),
                        onTap: () => _showDiscountModal(discount),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createDiscount,
        backgroundColor: const Color(0xFF7209B7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

