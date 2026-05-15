import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/auth/data/auth_service.dart';
import 'package:iosmobileapp/features/team/data/team_service.dart';
import 'package:iosmobileapp/features/team/domain/worker.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_bloc.dart';
import 'package:iosmobileapp/features/team/presentation/widgets/worker_modal.dart';
import 'package:mocktail/mocktail.dart';

class MockTeamService extends Mock implements TeamService {}

class MockAuthService extends Mock implements AuthService {}

class MockOnboardingService extends Mock implements OnboardingService {}

void main() {
  late MockTeamService teamService;
  late MockAuthService authService;
  late MockOnboardingService onboardingService;
  late WorkersBloc bloc;

  setUp(() {
    teamService = MockTeamService();
    authService = MockAuthService();
    onboardingService = MockOnboardingService();
    bloc = WorkersBloc(
      service: teamService,
      authService: authService,
      onboardingService: onboardingService,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('Team feature integration', () {
    testWidgets(
      'desde WorkerModal, tocar Editar navega a pantalla de edicion',
      (tester) async {
        const worker = Worker(
          id: 5,
          name: 'Carlos Ruiz',
          specialization: 'Corte',
          photoUrl: 'https://carlos-profile.jpg',
          providerId: 33,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: bloc,
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: bloc,
                              child: const WorkerModal(
                                worker: worker,
                                isDeleting: false,
                              ),
                            ),
                          );
                        },
                        child: const Text('Abrir modal'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir modal'));
        await tester.pumpAndSettle();
        expect(find.text('Carlos Ruiz'), findsOneWidget);

        await tester.tap(find.widgetWithText(OutlinedButton, 'Editar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Editar trabajador'), findsOneWidget);
      },
    );

    testWidgets(
      'eliminar trabajador desde WorkerModal confirma y llama delete',
      (tester) async {
        const worker = Worker(
          id: 9,
          name: 'Ana Torres',
          specialization: 'Manicure',
          photoUrl: '',
          providerId: 12,
        );

        when(() => teamService.deleteWorker(9)).thenAnswer((_) async {});

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: bloc,
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: bloc,
                              child: const WorkerModal(
                                worker: worker,
                                isDeleting: false,
                              ),
                            ),
                          );
                        },
                        child: const Text('Abrir modal'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir modal'));
        await tester.pumpAndSettle();
        expect(find.text('Ana Torres'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Eliminar').first);
        await tester.pumpAndSettle();
        expect(find.text('Eliminar trabajador'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Eliminar').last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        verify(() => teamService.deleteWorker(9)).called(1);
        expect(find.text('Eliminar trabajador'), findsNothing);
      },
    );
  });
}
