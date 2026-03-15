import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/studios/cubits/my_studio_cubit.dart';
import 'package:upsessions/modules/studios/cubits/studios_state.dart';
import 'package:upsessions/modules/studios/cubits/studios_status.dart';
import 'package:upsessions/modules/studios/models/studio_entity.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/modules/studios/services/studio_image_service.dart';
import 'package:upsessions/modules/studios/ui/provider/studio_profile_page.dart';
import 'package:upsessions/modules/studios/ui/widgets/studio_profile_form.dart';

class _MockMyStudioCubit extends MockCubit<StudiosState>
    implements MyStudioCubit {}

class _MockStudiosRepository extends Mock implements StudiosRepository {}

class _MockStudioImageService extends Mock implements StudioImageService {}

void main() {
  late _MockMyStudioCubit myStudioCubit;
  late _MockStudiosRepository studiosRepository;
  late _MockStudioImageService studioImageService;
  late StreamController<StudiosState> myStudioStates;
  late StudioEntity studio;

  setUpAll(() {
    registerFallbackValue(_buildStudio());
  });

  setUp(() async {
    studio = _buildStudio();
    myStudioCubit = _MockMyStudioCubit();
    studiosRepository = _MockStudiosRepository();
    studioImageService = _MockStudioImageService();
    myStudioStates = StreamController<StudiosState>.broadcast();

    final initialState = StudiosState(
      status: StudiosStatus.success,
      myStudio: studio,
    );

    when(() => myStudioCubit.state).thenReturn(initialState);
    when(() => myStudioCubit.updateMyStudio(any())).thenAnswer((_) async {});

    whenListen(
      myStudioCubit,
      myStudioStates.stream,
      initialState: initialState,
    );

    await getIt.reset();
    getIt.registerSingleton<StudiosRepository>(studiosRepository);
    getIt.registerSingleton<StudioImageService>(studioImageService);
  });

  tearDown(() async {
    await myStudioStates.close();
    await myStudioCubit.close();
    await getIt.reset();
  });

  testWidgets('shows profile snackbar only after save success state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<MyStudioCubit>.value(
            value: myStudioCubit,
            child: const StudioProfilePage(),
          ),
        ),
      ),
    );
    await tester.pump();

    final updatedStudio = studio.copyWith(name: 'Updated Name');
    final profileForm = tester.widget<StudioProfileForm>(
      find.byType(StudioProfileForm),
    );
    profileForm.onSave(updatedStudio);
    await tester.pump();

    verify(() => myStudioCubit.updateMyStudio(updatedStudio)).called(1);
    expect(find.text('Profile updated successfully.'), findsNothing);

    myStudioStates.add(
      StudiosState(status: StudiosStatus.loading, myStudio: studio),
    );
    myStudioStates.add(
      StudiosState(status: StudiosStatus.success, myStudio: updatedStudio),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Profile updated successfully.'), findsOneWidget);
  });

  testWidgets('shows profile snackbar with error when save fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<MyStudioCubit>.value(
            value: myStudioCubit,
            child: const StudioProfilePage(),
          ),
        ),
      ),
    );
    await tester.pump();

    final profileForm = tester.widget<StudioProfileForm>(
      find.byType(StudioProfileForm),
    );
    profileForm.onSave(studio);
    await tester.pump();

    myStudioStates.add(
      StudiosState(status: StudiosStatus.loading, myStudio: studio),
    );
    myStudioStates.add(
      StudiosState(
        status: StudiosStatus.failure,
        myStudio: studio,
        errorMessage: 'save failed',
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('save failed'), findsOneWidget);
  });
}

StudioEntity _buildStudio() {
  return StudioEntity(
    id: 'studio-1',
    ownerId: 'owner-1',
    name: 'Studio One',
    description: 'Description',
    address: 'Address',
    contactEmail: 'studio@test.com',
    contactPhone: '+34123456789',
    cif: 'B12345678',
    businessName: 'Studio One SL',
    vatNumber: 'ES12345678A',
    licenseNumber: 'LIC-123',
    openingHours: const {'mon': '09:00-18:00'},
    city: 'Madrid',
    province: 'Madrid',
    postalCode: '28001',
    maxRoomCapacity: 20,
    accessibilityInfo: 'Wheelchair access',
    noiseOrdinanceCompliant: true,
    insuranceExpiry: DateTime(2027, 1, 1),
  );
}
