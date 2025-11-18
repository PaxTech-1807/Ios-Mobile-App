import 'package:equatable/equatable.dart';

abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReviewsRequested extends ReviewsEvent {
  final int? providerId;

  const LoadReviewsRequested({this.providerId});

  @override
  List<Object?> get props => [providerId];
}

class FilterReviewsRequested extends ReviewsEvent {
  final int? minRating;
  final String? timeFilter; // null (todos), 'week' (hace 1 semana), 'month' (hace 1 mes)

  const FilterReviewsRequested({
    this.minRating,
    this.timeFilter,
  });

  @override
  List<Object?> get props => [minRating, timeFilter];
}

class DeleteReviewRequested extends ReviewsEvent {
  final int reviewId;

  const DeleteReviewRequested(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

