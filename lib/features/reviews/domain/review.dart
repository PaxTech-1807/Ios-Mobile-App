class Review {
  final int id;
  final int? clientId;
  final String clientName;
  final String? clientFirstName;
  final String? clientLastName;
  final String? clientEmail;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final int? providerId;

  Review({
    required this.id,
    this.clientId,
    required this.clientName,
    this.clientFirstName,
    this.clientLastName,
    this.clientEmail,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.providerId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Estructura real del API:
    // { "id": 1, "clientId": 1, "providerId": 1, "rating": 4, "review": "...", "read": false }
    
    // Obtener clientId y crear nombre genérico
    final clientId = json['clientId'] as int? ?? json['client_id'] as int?;
    final clientName = json['clientName'] as String? ?? 
                      json['client_name'] as String? ??
                      (clientId != null ? 'Cliente #$clientId' : 'Cliente');
    
    // El campo es 'review', no 'comment'
    final comment = json['review'] as String? ?? 
                   json['comment'] as String? ?? 
                   json['content'] as String? ?? 
                   '';
    
    final clientEmail = json['clientEmail'] as String? ?? 
                       json['client_email'] as String?;
    
    final rating = json['rating'] != null 
        ? (json['rating'] as num).toDouble() 
        : 0.0;
    
    // No hay fecha en el JSON, usar DateTime.now() como fallback
    DateTime createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.parse(json['createdAt'] as String);
    } else if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at'] as String);
    } else if (json['date'] != null) {
      createdAt = DateTime.parse(json['date'] as String);
    } else {
      // Si no hay fecha, usar la fecha actual
      createdAt = DateTime.now();
    }
    
    final providerId = json['providerId'] as int? ?? 
                      json['provider_id'] as int?;

    return Review(
      id: json['id'] as int,
      clientId: clientId,
      clientName: clientName,
      clientFirstName: null, // Se llenará después con la info del cliente
      clientLastName: null, // Se llenará después con la info del cliente
      clientEmail: clientEmail,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      providerId: providerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'rating': rating,
      'review': comment, // El API usa 'review', no 'comment'
      'createdAt': createdAt.toIso8601String(),
      'providerId': providerId,
    };
  }

  String getDisplayName() {
    if (clientFirstName != null && clientLastName != null) {
      return '${clientFirstName!} ${clientLastName!}'.trim();
    }
    return clientName;
  }

  String getInitials() {
    if (clientFirstName != null && clientLastName != null) {
      final first = clientFirstName!.isNotEmpty 
          ? clientFirstName![0].toUpperCase() 
          : '';
      final last = clientLastName!.isNotEmpty 
          ? clientLastName![0].toUpperCase() 
          : '';
      return '$first$last'.isEmpty ? '?' : '$first$last';
    }
    
    if (clientName.isEmpty) return '?';
    final parts = clientName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    }
    final first = parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
    final last = parts.last.isNotEmpty ? parts.last[0].toUpperCase() : '';
    final initials = '$first$last';
    return initials.isEmpty ? '?' : initials;
  }

  Review copyWith({
    int? id,
    int? clientId,
    String? clientName,
    String? clientFirstName,
    String? clientLastName,
    String? clientEmail,
    double? rating,
    String? comment,
    DateTime? createdAt,
    int? providerId,
  }) {
    return Review(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientFirstName: clientFirstName ?? this.clientFirstName,
      clientLastName: clientLastName ?? this.clientLastName,
      clientEmail: clientEmail ?? this.clientEmail,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      providerId: providerId ?? this.providerId,
    );
  }
}

