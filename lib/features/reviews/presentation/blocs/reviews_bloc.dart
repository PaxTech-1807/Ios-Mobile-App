import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/auth/data/auth_service.dart';
import 'package:iosmobileapp/features/reviews/data/client_service.dart';
import 'package:iosmobileapp/features/reviews/data/reviews_service.dart';
import 'package:iosmobileapp/features/reviews/domain/review.dart';
import 'package:iosmobileapp/features/reviews/presentation/blocs/reviews_event.dart';
import 'package:iosmobileapp/features/reviews/presentation/blocs/reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  ReviewsBloc({
    ReviewsService? reviewsService,
    AuthService? authService,
    OnboardingService? onboardingService,
    ClientService? clientService,
  })  : _reviewsService = reviewsService ?? ReviewsService(),
        _authService = authService ?? AuthService(),
        _onboardingService = onboardingService ?? OnboardingService(),
        _clientService = clientService ?? ClientService(),
        super(ReviewsInitial()) {
    on<LoadReviewsRequested>(_onLoadReviewsRequested);
    on<FilterReviewsRequested>(_onFilterReviewsRequested);
    on<DeleteReviewRequested>(_onDeleteReviewRequested);
  }

  final ReviewsService _reviewsService;
  final AuthService _authService;
  final OnboardingService _onboardingService;
  final ClientService _clientService;

  Future<void> _onLoadReviewsRequested(
    LoadReviewsRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(ReviewsLoading());

    try {
      // 1. Obtener todas las reseñas del API
      final allReviews = await _reviewsService.getReviews();
      
      // 2. Obtener el providerId del usuario logueado
      int? providerId = event.providerId;
      if (providerId == null) {
        final userId = await _onboardingService.getUserId();
        if (userId != null) {
          final token = await _onboardingService.getJwtToken();
          if (token != null) {
            final provider = await _authService.getProviderByUserId(
              userId: userId,
              token: token,
            );
            providerId = provider?.id;
          }
        }
      }

      // 3. Filtrar las reseñas por providerId
      final filteredReviews = providerId != null
          ? allReviews.where((review) => review.providerId == providerId).toList()
          : <Review>[];
      
      // 4. Obtener información de clientes para las reseñas filtradas
      final clientIds = filteredReviews
          .where((review) => review.clientId != null)
          .map((review) => review.clientId!)
          .toSet()
          .toList();
      
      if (clientIds.isNotEmpty) {
        try {
          final clientsMap = await _clientService.getClientsByIds(clientIds);
          
          // Actualizar las reseñas con la información del cliente
          final reviewsWithClientInfo = filteredReviews.map((review) {
            if (review.clientId != null && clientsMap.containsKey(review.clientId)) {
              final clientInfo = clientsMap[review.clientId]!;
              return review.copyWith(
                clientFirstName: clientInfo.firstName,
                clientLastName: clientInfo.lastName,
                clientName: clientInfo.fullName,
              );
            }
            return review;
          }).toList();
          
          // 5. Ordenar por fecha (más recientes primero)
          reviewsWithClientInfo.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          emit(ReviewsLoaded(
            reviews: reviewsWithClientInfo,
            filteredReviews: reviewsWithClientInfo,
          ));
          return;
        } catch (e) {
          // Si falla obtener info de clientes, continuar sin ella
          print('Error loading client info: $e');
        }
      }
      
      // 5. Ordenar por fecha (más recientes primero)
      filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      emit(ReviewsLoaded(
        reviews: filteredReviews,
        filteredReviews: filteredReviews,
      ));
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }

  void _onFilterReviewsRequested(
    FilterReviewsRequested event,
    Emitter<ReviewsState> emit,
  ) {
    if (state is! ReviewsLoaded) return;

    final currentState = state as ReviewsLoaded;
    List<Review> filtered = List.from(currentState.reviews);

    // Filtrar por rating mínimo
    if (event.minRating != null) {
      filtered = filtered
          .where((review) => review.rating >= event.minRating!)
          .toList();
    }

    // Filtrar por tiempo
    if (event.timeFilter != null) {
      final now = DateTime.now();
      final cutoffDate = event.timeFilter == 'week'
          ? now.subtract(const Duration(days: 7))
          : now.subtract(const Duration(days: 30));
      
      filtered = filtered
          .where((review) => review.createdAt.isAfter(cutoffDate))
          .toList();
    }

    // Ordenar por fecha (más recientes primero)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(currentState.copyWith(
      filteredReviews: filtered,
      minRating: event.minRating,
      timeFilter: event.timeFilter,
    ));
  }

  Future<void> _onDeleteReviewRequested(
    DeleteReviewRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    if (state is! ReviewsLoaded) return;

    try {
      await _reviewsService.deleteReview(event.reviewId);
      
      final currentState = state as ReviewsLoaded;
      final updatedReviews = currentState.reviews
          .where((review) => review.id != event.reviewId)
          .toList();
      
      // Aplicar filtros actuales a las nuevas reseñas
      final filtered = _applyFilters(
        updatedReviews,
        currentState.minRating,
        currentState.timeFilter,
      );

      emit(currentState.copyWith(
        reviews: updatedReviews,
        filteredReviews: filtered,
      ));
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }

  List<Review> _applyFilters(
    List<Review> reviews,
    int? minRating,
    String? timeFilter,
  ) {
    List<Review> filtered = List.from(reviews);

    if (minRating != null) {
      filtered = filtered
          .where((review) => review.rating >= minRating)
          .toList();
    }

    if (timeFilter != null) {
      final now = DateTime.now();
      final cutoffDate = timeFilter == 'week'
          ? now.subtract(const Duration(days: 7))
          : now.subtract(const Duration(days: 30));
      
      filtered = filtered
          .where((review) => review.createdAt.isAfter(cutoffDate))
          .toList();
    }

    // Ordenar por fecha (más recientes primero)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }
}

