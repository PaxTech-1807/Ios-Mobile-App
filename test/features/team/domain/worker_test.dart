import 'package:flutter_test/flutter_test.dart';
import 'package:iosmobileapp/features/team/domain/worker.dart';

void main() {
  group('Worker', () {
    test('fromJson mapea todos los campos', () {
      final worker = Worker.fromJson(<String, dynamic>{
        'id': 10,
        'name': 'Juan',
        'specialization': 'Maquillaje',
        'photoUrl': 'https://juan-profile.jpg',
        'providerId': 99,
      });

      expect(worker.id, 10);
      expect(worker.name, 'Juan');
      expect(worker.specialization, 'Maquillaje');
      expect(worker.photoUrl, 'https://juan-profile.jpg');
      expect(worker.providerId, 99);
    });

    test('fromJson usa valores por defecto cuando faltan campos opcionales', () {
      final worker = Worker.fromJson(<String, dynamic>{'id': 1});

      expect(worker.id, 1);
      expect(worker.name, isEmpty);
      expect(worker.specialization, isEmpty);
      expect(worker.photoUrl, isEmpty);
      expect(worker.providerId, 0);
    });

    test('copyWith actualiza solo campos enviados', () {
      const worker = Worker(
        id: 1,
        name: 'Ana',
        specialization: 'Tintes',
        photoUrl: 'x',
        providerId: 4,
      );

      final updated = worker.copyWith(name: 'Maria', providerId: 7);

      expect(updated.id, 1);
      expect(updated.name, 'Maria');
      expect(updated.specialization, 'Tintes');
      expect(updated.photoUrl, 'x');
      expect(updated.providerId, 7);
    });

    test('toJson serializa correctamente', () {
      const worker = Worker(
        id: 3,
        name: 'Pedro',
        specialization: 'Peluqueria',
        photoUrl: 'photo',
        providerId: 11,
      );

      expect(worker.toJson(), <String, dynamic>{
        'id': 3,
        'name': 'Pedro',
        'specialization': 'Peluqueria',
        'photoUrl': 'photo',
        'providerId': 11,
      });
    });
  });

  group('WorkerRequest', () {
    test('fromWorker usa url por defecto cuando worker.photoUrl esta vacio', () {
      const worker = Worker(
        id: 1,
        name: 'Sofia',
        specialization: 'Maquillaje',
        photoUrl: '',
        providerId: 8,
      );

      final request = WorkerRequest.fromWorker(worker);

      expect(request.photoUrl, 'https://example.com');
    });

    test('toJson usa url por defecto cuando photoUrl esta vacio o solo espacios', () {
      const request = WorkerRequest(
        name: 'Luis',
        specialization: 'Manicure',
        photoUrl: '   ',
        providerId: 5,
      );

      expect(request.toJson()['photoUrl'], 'https://example.com');
    });

    test('toJson recorta espacios en photoUrl no vacia', () {
      const request = WorkerRequest(
        name: 'Rosa',
        specialization: 'Masajes',
        photoUrl: '  https://rosa-profile.jpg  ',
        providerId: 6,
      );

      expect(request.toJson()['photoUrl'], 'https://rosa-profile.jpg');
    });
  });
}
