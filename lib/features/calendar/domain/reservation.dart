/// Modelo que representa una reserva (Reservation) y sus objetos anidados.
class Reservation {
	final int id;
	final int clientId;
	final ReservationProvider provider;
	final PaymentInfo paymentId;
	final TimeSlot timeSlot;
	final Worker workerId;

	Reservation({
		required this.id,
		required this.clientId,
		required this.provider,
		required this.paymentId,
		required this.timeSlot,
		required this.workerId,
	});

	factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
				id: json['id'] as int,
				clientId: json['clientId'] as int,
				provider: ReservationProvider.fromJson(json['provider'] as Map<String, dynamic>),
				paymentId: PaymentInfo.fromJson(json['paymentId'] as Map<String, dynamic>),
				timeSlot: TimeSlot.fromJson(json['timeSlot'] as Map<String, dynamic>),
				workerId: Worker.fromJson(json['workerId'] as Map<String, dynamic>),
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'clientId': clientId,
				'provider': provider.toJson(),
				'paymentId': paymentId.toJson(),
				'timeSlot': timeSlot.toJson(),
				'workerId': workerId.toJson(),
			};

	Reservation copyWith({
		int? id,
		int? clientId,
		ReservationProvider? provider,
		PaymentInfo? paymentId,
		TimeSlot? timeSlot,
		Worker? workerId,
	}) {
		return Reservation(
			id: id ?? this.id,
			clientId: clientId ?? this.clientId,
			provider: provider ?? this.provider,
			paymentId: paymentId ?? this.paymentId,
			timeSlot: timeSlot ?? this.timeSlot,
			workerId: workerId ?? this.workerId,
		);
	}

	@override
	bool operator ==(Object other) {
		if (identical(this, other)) return true;
		return other is Reservation &&
				other.id == id &&
				other.clientId == clientId &&
				other.provider == provider &&
				other.paymentId == paymentId &&
				other.timeSlot == timeSlot &&
				other.workerId == workerId;
	}

	@override
	int get hashCode => Object.hash(id, clientId, provider, paymentId, timeSlot, workerId);
}

class ReservationProvider {
	final int id;
	final String name;
	final String companyName;

	ReservationProvider({
		required this.id,
		required this.name,
		required this.companyName,
	});

	factory ReservationProvider.fromJson(Map<String, dynamic> json) => ReservationProvider(
				id: json['id'] as int,
				name: json['name'] as String,
				companyName: json['companyName'] as String,
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'companyName': companyName,
			};

	@override
	bool operator ==(Object other) {
		return identical(this, other) ||
				(other is ReservationProvider && other.id == id && other.name == name && other.companyName == companyName);
	}

	@override
	int get hashCode => Object.hash(id, name, companyName);
}

class PaymentInfo {
	final int id;
	final double amount;
	final String currency;
	final bool status;

	PaymentInfo({
		required this.id,
		required this.amount,
		required this.currency,
		required this.status,
	});

	factory PaymentInfo.fromJson(Map<String, dynamic> json) => PaymentInfo(
				id: json['id'] as int,
				amount: (json['amount'] is int) ? (json['amount'] as int).toDouble() : (json['amount'] as num).toDouble(),
				currency: json['currency'] as String,
				status: json['status'] as bool,
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'amount': amount,
				'currency': currency,
				'status': status,
			};

	@override
	bool operator ==(Object other) {
		return identical(this, other) ||
				(other is PaymentInfo && other.id == id && other.amount == amount && other.currency == currency && other.status == status);
	}

	@override
	int get hashCode => Object.hash(id, amount, currency, status);
}

class TimeSlot {
	final int id;
	final DateTime startTime;
	final DateTime endTime;
	final bool status;
	final String type;

	TimeSlot({
		required this.id,
		required this.startTime,
		required this.endTime,
		required this.status,
		required this.type,
	});

	factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
				id: json['id'] as int,
				startTime: DateTime.parse(json['startTime'] as String),
				endTime: DateTime.parse(json['endTime'] as String),
				status: json['status'] as bool,
				type: json['type'] as String,
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'startTime': startTime.toIso8601String(),
				'endTime': endTime.toIso8601String(),
				'status': status,
				'type': type,
			};

	@override
	bool operator ==(Object other) {
		return identical(this, other) ||
				(other is TimeSlot &&
						other.id == id &&
						other.startTime == startTime &&
						other.endTime == endTime &&
						other.status == status &&
						other.type == type);
	}

	@override
	int get hashCode => Object.hash(id, startTime, endTime, status, type);
}

class Worker {
	final int id;
	final String name;
	final String specialization;

	Worker({
		required this.id,
		required this.name,
		required this.specialization,
	});

	factory Worker.fromJson(Map<String, dynamic> json) => Worker(
				id: json['id'] as int,
				name: json['name'] as String,
				specialization: json['specialization'] as String,
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'specialization': specialization,
			};

	@override
	bool operator ==(Object other) {
		return identical(this, other) ||
				(other is Worker && other.id == id && other.name == name && other.specialization == specialization);
	}

	@override
	int get hashCode => Object.hash(id, name, specialization);
}