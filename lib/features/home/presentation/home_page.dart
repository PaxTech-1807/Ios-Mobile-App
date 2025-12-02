import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/profile/data/geocoding_service.dart';
import 'package:iosmobileapp/features/profile/data/providerProfile_service.dart';
import 'package:iosmobileapp/features/profile/domain/providerProfile.dart';
import 'package:iosmobileapp/features/reviews/presentation/blocs/reviews_bloc.dart';
import 'package:iosmobileapp/features/reviews/presentation/blocs/reviews_event.dart';
import 'package:iosmobileapp/features/reviews/presentation/blocs/reviews_state.dart';
import 'package:iosmobileapp/features/reviews/presentation/widgets/review_card.dart';
import 'package:iosmobileapp/features/reviews/presentation/widgets/review_filter_bar.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_bloc.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_event.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_state.dart';
import 'package:iosmobileapp/features/service/data/services_service.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_bloc.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_event.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_state.dart';
import 'package:iosmobileapp/features/team/data/team_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.onNavigateToServices,
    this.onNavigateToTeam,
    this.onNavigateToCalendar,
  });

  final VoidCallback? onNavigateToServices;
  final VoidCallback? onNavigateToTeam;
  final VoidCallback? onNavigateToCalendar;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _onboardingService = OnboardingService();
  final _profileService = ProviderprofileService();
  final _geocodingService = GeocodingService();
  String? _companyName;
  ProviderProfile? _profile;
  String? _locationAddress;
  int? _selectedRating;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
    _loadProfile();
  }

  Future<void> _loadCompanyName() async {
    final companyName = await _onboardingService.getCompanyName();
    if (mounted) {
      setState(() {
        _companyName = companyName;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      print('🏠 [HomePage] Cargando perfil...');
      final profile = await _profileService.getCurrentProfile();
      print('✅ [HomePage] Perfil cargado: location="${profile.location}"');

      // Convertir coordenadas a dirección legible si existe
      String? locationAddress;
      if (profile.location.isNotEmpty && profile.location.contains(',')) {
        try {
          final parts = profile.location.split(',');
          if (parts.length == 2) {
            final lat = double.parse(parts[0].trim());
            final lon = double.parse(parts[1].trim());
            
            print('🗺️ [HomePage] Convirtiendo coordenadas a dirección...');
            locationAddress = await _geocodingService.reverseGeocode(lat, lon);
            print('✅ [HomePage] Dirección obtenida: $locationAddress');
          }
        } catch (e) {
          print('⚠️ [HomePage] Error al convertir coordenadas: $e');
        }
      }

      if (mounted) {
        setState(() {
          _profile = profile;
          _locationAddress = locationAddress;
        });
      }
    } catch (e) {
      print('❌ [HomePage] Error al cargar perfil: $e');
      // No mostrar error al usuario, simplemente no mostrar ubicación
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReviewsBloc()..add(const LoadReviewsRequested()),
        ),
        BlocProvider(
          create: (context) => ServicesBloc(service: ServicesService())
            ..add(const LoadServices()),
        ),
        BlocProvider(
          create: (context) => WorkersBloc(service: TeamService())
            ..add(const LoadWorkers()),
        ),
      ],
      child: _HomePageContent(
        companyName: _companyName,
        profile: _profile,
        locationAddress: _locationAddress,
        getInitials: _getInitials,
        selectedRating: _selectedRating,
        selectedSort: _selectedSort,
        onRatingChanged: (rating) {
          setState(() {
            _selectedRating = rating;
          });
        },
        onSortChanged: (sort) {
          setState(() {
            _selectedSort = sort;
          });
        },
      ),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent({
    required this.companyName,
    required this.profile,
    required this.locationAddress,
    required this.getInitials,
    required this.selectedRating,
    required this.selectedSort,
    required this.onRatingChanged,
    required this.onSortChanged,
  });

  final String? companyName;
  final ProviderProfile? profile;
  final String? locationAddress;
  final String Function(String?) getInitials;
  final int? selectedRating;
  final String? selectedSort;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<String?> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // Actualizar todos los blocs
              context.read<ReviewsBloc>().add(const LoadReviewsRequested());
              context.read<WorkersBloc>().add(const LoadWorkers());
              context.read<ServicesBloc>().add(const LoadServices());
              // Recargar perfil también
              if (context.mounted) {
                final state = context.findAncestorStateOfType<HomePageState>();
                state?.._loadProfile();
              }
              // Esperar un poco para que se complete el refresh
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: const Color(0xFF7209B7),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 16),
              
              // Header blanco flotante
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7209B7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF7209B7).withOpacity(0.2),
                          width: 1.5,
                        ),
                        image: profile?.profileImageUrl != null &&
                                profile!.profileImageUrl != 'to Choose' &&
                                profile!.profileImageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(profile!.profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profile?.profileImageUrl == null ||
                              profile!.profileImageUrl == 'to Choose' ||
                              profile!.profileImageUrl!.isEmpty
                          ? Center(
                              child: Text(
                                getInitials(companyName),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7209B7),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            companyName ?? 'Mi Salón',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  locationAddress ??
                                      (profile?.location.isNotEmpty ?? false
                                          ? profile!.location
                                          : 'Ubicación no configurada'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Welcome Section
              Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gestiona tu salón de forma eficiente',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<WorkersBloc, WorkersState>(
                      builder: (context, state) {
                        final count = state.workers.length;
                        return _StatCard(
                          icon: Icons.people_outline,
                          label: 'Trabajadores',
                          value: count.toString(),
                          color: const Color(0xFF7209B7),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlocBuilder<ServicesBloc, ServicesState>(
                      builder: (context, state) {
                        final count = state.services.length;
                        return _StatCard(
                          icon: Icons.content_cut,
                          label: 'Servicios',
                          value: count.toString(),
                          color: const Color(0xFF9D4EDD),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today,
                      label: 'Reservas hoy',
                      value: '0',
                      color: const Color(0xFF7209B7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.trending_up,
                      label: 'Este mes',
                      value: '0',
                      color: const Color(0xFF9D4EDD),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Reviews Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reseñas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  BlocBuilder<ReviewsBloc, ReviewsState>(
                    builder: (context, state) {
                      if (state is ReviewsLoaded) {
                        return Text(
                          '${state.filteredReviews.length} reseña${state.filteredReviews.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Filter Bar
              BlocBuilder<ReviewsBloc, ReviewsState>(
                builder: (context, state) {
                  return ReviewFilterBar(
                    selectedRating: selectedRating,
                    selectedSort: selectedSort,
                    onRatingChanged: (rating) {
                      onRatingChanged(rating);
                      context.read<ReviewsBloc>().add(
                        FilterReviewsRequested(
                          minRating: rating,
                          timeFilter: selectedSort,
                        ),
                      );
                    },
                    onSortChanged: (sort) {
                      onSortChanged(sort);
                      context.read<ReviewsBloc>().add(
                        FilterReviewsRequested(
                          minRating: selectedRating,
                          timeFilter: sort,
                        ),
                      );
                    },
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Reviews List
              BlocBuilder<ReviewsBloc, ReviewsState>(
                builder: (context, state) {
                  if (state is ReviewsLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF7209B7),
                        ),
                      ),
                    );
                  }
                  
                  if (state is ReviewsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar reseñas',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  if (state is ReviewsLoaded) {
                    if (state.filteredReviews.isEmpty) {
                      final hasFilters = state.minRating != null || state.timeFilter != null;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                hasFilters ? 'No hay reseñas con esas características' : 'No hay reseñas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hasFilters 
                                    ? 'Intenta cambiar los filtros para ver más reseñas'
                                    : 'Aún no has recibido reseñas',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Column(
                      children: state.filteredReviews
                          .map((review) => ReviewCard(review: review))
                          .toList(),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
              
              const SizedBox(height: 20),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

