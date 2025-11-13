// features/calendar/domain/reservation_request.dart

class ReservationRequest {
  final int clientId;
  final int providerId;
  final int serviceId;
  final int workerId;
  final int timeSlotId; // ¡CAMBIO! Ahora es un ID

  ReservationRequest({
    required this.clientId,
    required this.providerId,
    required this.serviceId,
    required this.workerId,
    required this.timeSlotId, // ¡CAMBIO!
  });

  Map<String, dynamic> toJson() {
    // ¡CAMBIO! El JSON ahora es simple, como el de Swagger
    return {
      'clientId': clientId,
      'providerId': providerId,
      'serviceId': serviceId,
      'workerId': workerId,
      'timeSlotId': timeSlotId,
    };
  }
}