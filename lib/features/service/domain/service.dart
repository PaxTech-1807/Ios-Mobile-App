class Service {
  final int id;
  final String name;
  final int duration;
  final double price;
  final int providerId;
  final bool status;

  const Service({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.providerId,
    required this.status,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final dynamic statusValue = json['status'];
    bool status;
    if (statusValue is bool) {
      status = statusValue;
    } else if (statusValue is num) {
      status = statusValue != 0;
    } else if (statusValue is String) {
      status =
          statusValue.toLowerCase() == 'true' ||
          statusValue.toLowerCase() == 'active';
    } else {
      status = true;
    }

    return Service(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      providerId: (json['providerId'] as num?)?.toInt() ?? 0,
      status: status,
    );
  }

  Service copyWith({
    int? id,
    String? name,
    int? duration,
    double? price,
    int? providerId,
    bool? status,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      providerId: providerId ?? this.providerId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'price': price,
      'providerId': providerId,
      'status': status,
    };
  }
}

class ServiceRequest {
  final String name;
  final int duration;
  final double price;
  final bool? status;
  final int? providerId;

  const ServiceRequest({
    required this.name,
    required this.duration,
    required this.price,
    this.status,
    this.providerId,
  });

  factory ServiceRequest.fromService(Service service) {
    return ServiceRequest(
      name: service.name,
      duration: service.duration,
      price: service.price,
      status: service.status,
      providerId: service.providerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'price': price,
      if (status != null) 'status': status,
      if (providerId != null) 'providerId': providerId,
    };
  }
}

extension ServiceRequestCopy on ServiceRequest {
  ServiceRequest copyWith({
    String? name,
    int? duration,
    double? price,
    bool? status,
    int? providerId,
  }) {
    return ServiceRequest(
      name: name ?? this.name,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      status: status ?? this.status,
      providerId: providerId ?? this.providerId,
    );
  }
}
