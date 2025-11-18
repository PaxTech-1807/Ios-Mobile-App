import 'package:equatable/equatable.dart';
import 'package:iosmobileapp/features/reviews/domain/review.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<Review> reviews;
  final List<Review> filteredReviews;
  final int? minRating;
  final String? timeFilter;

  const ReviewsLoaded({
    required this.reviews,
    required this.filteredReviews,
    this.minRating,
    this.timeFilter,
  });

  ReviewsLoaded copyWith({
    List<Review>? reviews,
    List<Review>? filteredReviews,
    int? minRating,
    String? timeFilter,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      filteredReviews: filteredReviews ?? this.filteredReviews,
      minRating: minRating ?? this.minRating,
      timeFilter: timeFilter ?? this.timeFilter,
    );
  }

  @override
  List<Object?> get props => [reviews, filteredReviews, minRating, timeFilter];
}

class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError(this.message);

  @override
  List<Object?> get props => [message];
}

