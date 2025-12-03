import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/reviews/domain/review.dart';

class ReviewsService {
  ReviewsService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final _onboardingService = OnboardingService();

  static const String _baseUrl =
      'https://paxtech.azurewebsites.net/api/v1/reviews';

  Future<Map<String, String>> get _headers async {
    final token = await _onboardingService.getJwtToken();
    if (token == null || token.isEmpty) {
      throw HttpException(
        'No se encontró token de autenticación. Por favor inicia sesión nuevamente.',
        uri: Uri.parse(_baseUrl),
      );
    }
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  Future<List<Review>> getReviews() async {
    final headers = await _headers;
    final uri = Uri.parse(_baseUrl);
    
    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      if (response.body.isEmpty) {
        return <Review>[];
      }
      final decoded = jsonDecode(response.body);
      if (decoded == null) {
        return <Review>[];
      }

      if (decoded is List) {
        return decoded
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return <Review>[];
    }
    if (response.statusCode == HttpStatus.notFound) {
      return <Review>[];
    }

    throw HttpException(
      'Failed to load reviews. Status code: ${response.statusCode}',
      uri: uri,
    );
  }

  Future<Review> createReview({
    required String clientName,
    String? clientEmail,
    required double rating,
    required String comment,
    required int providerId,
  }) async {
    final headers = await _headers;
    final body = jsonEncode({
      'clientName': clientName,
      'clientEmail': clientEmail,
      'rating': rating,
      'comment': comment,
      'providerId': providerId,
    });

    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      return Review.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw HttpException(
      'Failed to create review. Status code: ${response.statusCode}',
      uri: Uri.parse(_baseUrl),
    );
  }

  Future<void> deleteReview(int reviewId) async {
    final headers = await _headers;
    final uri = Uri.parse('$_baseUrl/$reviewId');
    final response = await _client.delete(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.noContent) {
      return;
    }

    throw HttpException(
      'Failed to delete review $reviewId. Status code: ${response.statusCode}',
      uri: uri,
    );
  }
}

