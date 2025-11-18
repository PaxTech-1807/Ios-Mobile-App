import 'package:flutter/material.dart';

import '../../../../core/services/onboarding_service.dart';
import '../widgets/profile_info_row.dart';
import '../widgets/profile_section_card.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final _onboardingService = OnboardingService();
  String? _companyName;

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
          'Perfil del negocio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7209B7),
            ),
            child: const Text(
              'Editar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileIdentityCard(companyName: _companyName, getInitials: _getInitials),
            const SizedBox(height: 20),
            _InfoSectionCard(
              title: 'Información del negocio',
              children: [
                _InfoRow(
                  icon: Icons.store_mall_directory_outlined,
                  label: 'Nombre de empresa',
                  value: _companyName ?? 'Mi Salón',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.place_outlined,
                  label: 'Dirección',
                  value: 'Av. Primavera 123, San Borja',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Número de celular',
                  value: '+51 987654321',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'Sobre nosotros',
              children: [
                _InfoRow(
                  label: 'Descripción',
                  value: 'Somos especialistas en cortes y tratamientos capilares personalizados para cada estilo.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'Horarios',
              children: [
                _InfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'Lun - Sáb',
                  value: '09:00 am — 08:00 pm',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Dom',
                  value: '10:00 am — 04:00 pm',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'Redes sociales',
              children: [
                _InfoRow(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  value: '@glowgo',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  value: '/glowgo',
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                getInitials(companyName),
                style: const TextStyle(
                  fontSize: 24,
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
                  'Salón de belleza y barbería especializada.',
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

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7209B7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF7209B7),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}