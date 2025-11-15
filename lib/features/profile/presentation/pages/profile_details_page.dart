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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Editar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          _ProfileIdentityCard(theme: theme, companyName: _companyName, getInitials: _getInitials),
          ProfileSectionCard(
            title: 'Información del negocio',
            children: [
              ProfileInfoRow(
                icon: Icons.store_mall_directory_outlined,
                label: 'Nombre de empresa',
                value: _companyName ?? 'Mi Salón',
              ),
              ProfileInfoRow(
                icon: Icons.place_outlined,
                label: 'Dirección',
                value: 'Av. Primavera 123, San Borja',
              ),
              ProfileInfoRow(
                icon: Icons.phone_outlined,
                label: 'Número de celular',
                value: '+51 987654321',
              ),
            ],
          ),
          const ProfileSectionCard(
            title: 'Sobre nosotros',
            children: [
              ProfileInfoRow(
                value:
                    'Somos especialistas en cortes y tratamientos capilares personalizados para cada estilo.',
                label: 'Descripción',
              ),
            ],
          ),
          const ProfileSectionCard(
            title: 'Horarios',
            children: [
              ProfileInfoRow(
                icon: Icons.schedule_outlined,
                label: 'Lun - Sáb',
                value: '[09:00 am] — [08:00 pm]',
              ),
              ProfileInfoRow(
                icon: Icons.schedule,
                label: 'Dom',
                value: '[10:00 am] — [04:00 pm]',
              ),
            ],
          ),
          const ProfileSectionCard(
            title: 'Redes sociales',
            children: [
              ProfileInfoRow(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                value: '@glowgo',
              ),
              ProfileInfoRow(
                icon: Icons.facebook,
                label: 'Facebook',
                value: '/glowgo',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
    required this.theme,
    required this.companyName,
    required this.getInitials,
  });

  final ThemeData theme;
  final String? companyName;
  final String Function(String?) getInitials;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              child: Text(
                getInitials(companyName),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName ?? 'Mi Salón',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Salón de belleza y barbería especializada.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}