import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../auth/presentation/login_screen.dart';
import '../widgets/profile_menu_item.dart';
import 'profile_details_page.dart';
import 'profile_notifications_page.dart';
import 'profile_subscription_page.dart';

class ProfileOverviewPage extends StatefulWidget {
  const ProfileOverviewPage({super.key});

  @override
  State<ProfileOverviewPage> createState() => _ProfileOverviewPageState();
}

class _ProfileOverviewPageState extends State<ProfileOverviewPage> {
  final _onboardingService = OnboardingService();
  String? _companyName;
  bool _isOpen = true; // Estado del salón

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
  }

  Future<void> _loadCompanyName() async {
    final companyName = await _onboardingService.getCompanyName();
    if (mounted) {
      setState(() {
        _companyName = companyName;
      });
    }
  }

  void _toggleStatus() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Mostrar diálogo de confirmación
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7209B7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Borrar JWT y datos de sesión
      final onboardingService = OnboardingService();
      await onboardingService.logout();

      if (!context.mounted) return;

      // Redirigir a Login y limpiar el stack de navegación
      Navigator.of(context).pushAndRemoveUntil(
        AppRoutes.createFadeRoute(const LoginScreen()),
        (route) => false,
      );
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
          'Perfil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Summary Card (más compacta)
              _ProfileSummaryCard(
                companyName: _companyName,
                getInitials: _getInitials,
              ),
              const SizedBox(height: 12),
              
              // Estado clickeable fuera de la card
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleStatus,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _isOpen ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Estado: ${_isOpen ? 'Abierto' : 'Cerrado'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sección Configuración
              const Text(
                'Configuración',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              ProfileMenuItem(
                icon: Icons.store_mall_directory_outlined,
                title: 'Perfil del negocio',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileDetailsPage(),
                    ),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileNotificationsPage(),
                    ),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.workspace_premium_outlined,
                title: 'Suscripción',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileSubscriptionPage(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Logout Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7209B7),
                      Color(0xFF9D4EDD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7209B7).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleLogout(context),
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.companyName,
    required this.getInitials,
  });

  final String? companyName;
  final String Function(String?) getInitials;

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
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                getInitials(companyName),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName ?? 'Mi Salón',
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
                  'Cuenta de empresa',
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
