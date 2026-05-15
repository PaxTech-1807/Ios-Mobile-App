import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/auth/data/auth_service.dart';
import 'package:iosmobileapp/features/team/data/team_service.dart';
import 'package:iosmobileapp/features/team/domain/worker.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_bloc.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_event.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_state.dart';
import 'package:mocktail/mocktail.dart';

class MockTeamService extends Mock implements TeamService {}

class MockAuthService extends Mock implements AuthService {}

class MockOnboardingService extends Mock implements OnboardingService {}

class FakeWorkerRequest extends Fake implements WorkerRequest {}

void main() {
  late MockTeamService teamService;
  late MockAuthService authService;
  late MockOnboardingService onboardingService;

  setUpAll(() {
    registerFallbackValue(FakeWorkerRequest());
  });

  setUp(() {
    teamService = MockTeamService();
    authService = MockAuthService();
    onboardingService = MockOnboardingService();
  });

  WorkersBloc buildBloc() {
    return WorkersBloc(
      service: teamService,
      authService: authService,
      onboardingService: onboardingService,
    );
  }

  group('WorkersBloc', () {
    blocTest<WorkersBloc, WorkersState>(
      'LoadWorkers filtra por providerId y ordena alfabeticamente',
      build: () {
        when(() => teamService.getWorkers()).thenAnswer(
          (_) async => const <Worker>[
            Worker(
              id: 1,
              name: 'zeta',
              specialization: 'S1',
              photoUrl: '',
              providerId: 2,
            ),
            Worker(
              id: 2,
              name: 'alpha',
              specialization: 'S2',
              photoUrl: '',
              providerId: 2,
            ),
            Worker(
              id: 3,
              name: 'otro',
              specialization: 'S3',
              photoUrl: '',
              providerId: 7,
            ),
          ],
        );
        when(() => onboardingService.getUserId()).thenAnswer((_) async => 44);
        when(() => onboardingService.getJwtToken()).thenAnswer((_) async => 'jwt');
        when(
          () => authService.getProviderByUserId(userId: 44, token: 'jwt'),
        ).thenAnswer(
          (_) async => ProviderResponse(id: 2, companyName: 'Acme', userId: 44),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadWorkers()),
      expect: () => <Matcher>[
        isA<WorkersState>()
            .having((s) => s.status, 'status', WorkersStatus.loading)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<WorkersState>()
            .having((s) => s.status, 'status', WorkersStatus.success)
            .having((s) => s.workers.map((w) => w.name).toList(), 'names', <String>[
              'alpha',
              'zeta',
            ]),
      ],
    );

    blocTest<WorkersBloc, WorkersState>(
      'LoadWorkers devuelve lista vacia si no hay userId',
      build: () {
        when(() => teamService.getWorkers()).thenAnswer(
          (_) async => const <Worker>[
            Worker(
              id: 1,
              name: 'A',
              specialization: 'S1',
              photoUrl: '',
              providerId: 2,
            ),
          ],
        );
        when(() => onboardingService.getUserId()).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadWorkers()),
      expect: () => <Matcher>[
        isA<WorkersState>().having((s) => s.status, 'status', WorkersStatus.loading),
        isA<WorkersState>()
            .having((s) => s.status, 'status', WorkersStatus.success)
            .having((s) => s.workers, 'workers', isEmpty),
      ],
      verify: (_) {
        verifyNever(
          () => authService.getProviderByUserId(userId: any(named: 'userId'), token: any(named: 'token')),
        );
      },
    );

    blocTest<WorkersBloc, WorkersState>(
      'LoadWorkers emite failure cuando getWorkers falla',
      build: () {
        when(
          () => teamService.getWorkers(),
        ).thenThrow(Exception('error de red'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadWorkers()),
      expect: () => <Matcher>[
        isA<WorkersState>().having((s) => s.status, 'status', WorkersStatus.loading),
        isA<WorkersState>()
            .having((s) => s.status, 'status', WorkersStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', contains('error de red')),
      ],
    );

    blocTest<WorkersBloc, WorkersState>(
      'CreateWorkerRequested agrega worker y emite success de formulario',
      build: () {
        when(() => teamService.createWorker(any())).thenAnswer(
          (_) async => const Worker(
            id: 2,
            name: 'Ana',
            specialization: 'Tech',
            photoUrl: '',
            providerId: 1,
          ),
        );
        return buildBloc();
      },
      seed: () => const WorkersState(
        workers: <Worker>[
          Worker(
            id: 1,
            name: 'Zoe',
            specialization: 'Ops',
            photoUrl: '',
            providerId: 1,
          ),
        ],
      ),
      act: (bloc) => bloc.add(
        const CreateWorkerRequested(
          request: WorkerRequest(
            name: 'Ana',
            specialization: 'Tech',
            photoUrl: '',
            providerId: 1,
          ),
        ),
      ),
      expect: () => <Matcher>[
        isA<WorkersState>()
            .having((s) => s.formStatus, 'formStatus', WorkerFormStatus.submitting)
            .having((s) => s.formErrorMessage, 'formErrorMessage', isNull),
        isA<WorkersState>()
            .having((s) => s.formStatus, 'formStatus', WorkerFormStatus.success)
            .having((s) => s.workers.map((w) => w.name).toList(), 'names', <String>[
              'Ana',
              'Zoe',
            ]),
      ],
    );

    blocTest<WorkersBloc, WorkersState>(
      'UpdateWorkerRequested reemplaza worker y ordena lista',
      build: () {
        when(
          () => teamService.updateWorker(workerId: 1, request: any(named: 'request')),
        ).thenAnswer(
          (_) async => const Worker(
            id: 1,
            name: 'Aaron',
            specialization: 'Backend',
            photoUrl: '',
            providerId: 1,
          ),
        );
        return buildBloc();
      },
      seed: () => const WorkersState(
        workers: <Worker>[
          Worker(
            id: 1,
            name: 'Zoe',
            specialization: 'Ops',
            photoUrl: '',
            providerId: 1,
          ),
          Worker(
            id: 2,
            name: 'Luis',
            specialization: 'QA',
            photoUrl: '',
            providerId: 1,
          ),
        ],
      ),
      act: (bloc) => bloc.add(
        const UpdateWorkerRequested(
          workerId: 1,
          request: WorkerRequest(
            name: 'Aaron',
            specialization: 'Backend',
            photoUrl: '',
            providerId: 1,
          ),
        ),
      ),
      expect: () => <Matcher>[
        isA<WorkersState>().having(
          (s) => s.formStatus,
          'formStatus',
          WorkerFormStatus.submitting,
        ),
        isA<WorkersState>()
            .having((s) => s.formStatus, 'formStatus', WorkerFormStatus.success)
            .having((s) => s.workers.map((w) => w.name).toList(), 'names', <String>[
              'Aaron',
              'Luis',
            ]),
      ],
    );

    blocTest<WorkersBloc, WorkersState>(
      'DeleteWorkerRequested elimina worker al completar',
      build: () {
        when(() => teamService.deleteWorker(2)).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => const WorkersState(
        workers: <Worker>[
          Worker(
            id: 1,
            name: 'A',
            specialization: 'S1',
            photoUrl: '',
            providerId: 1,
          ),
          Worker(
            id: 2,
            name: 'B',
            specialization: 'S2',
            photoUrl: '',
            providerId: 1,
          ),
        ],
      ),
      act: (bloc) => bloc.add(const DeleteWorkerRequested(workerId: 2)),
      expect: () => <Matcher>[
        isA<WorkersState>()
            .having((s) => s.deletingWorkerId, 'deletingWorkerId', 2)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<WorkersState>()
            .having((s) => s.deletingWorkerId, 'deletingWorkerId', isNull)
            .having((s) => s.workers.map((w) => w.id).toList(), 'ids', <int>[1]),
      ],
    );
  });
}
