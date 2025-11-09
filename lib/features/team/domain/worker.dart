class Worker {
  final int id;
  final String name;
  final String specialization;
  final String photoUrl;
  final int providerId;

  const Worker({
    required this.id,
    required this.name,
    required this.specialization,
    required this.photoUrl,
    required this.providerId,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      providerId: json['providerId'] as int? ?? 0,
    );
  }

  Worker copyWith({
    int? id,
    String? name,
    String? specialization,
    String? photoUrl,
    int? providerId,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      photoUrl: photoUrl ?? this.photoUrl,
      providerId: providerId ?? this.providerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'photoUrl': photoUrl,
      'providerId': providerId,
    };
  }
}

class WorkerRequest {
  final String name;
  final String specialization;
  final String photoUrl;
  final int providerId;

  const WorkerRequest({
    required this.name,
    required this.specialization,
    required this.photoUrl,
    required this.providerId,
  });

  factory WorkerRequest.fromWorker(Worker worker) {
    return WorkerRequest(
      name: worker.name,
      specialization: worker.specialization,
      photoUrl: worker.photoUrl,
      providerId: worker.providerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialization': specialization,
      'photoUrl': photoUrl,
      'providerId': providerId,
    };
  }
}
