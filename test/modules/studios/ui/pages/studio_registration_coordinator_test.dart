import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/studios/cubits/my_studio_cubit.dart';
import 'package:upsessions/modules/studios/models/studio_entity.dart';
import 'package:upsessions/modules/studios/ui/pages/studio_registration_coordinator.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

class MockMyStudioCubit extends Mock implements MyStudioCubit {}

void main() {
  late MockAuthCubit authCubit;
  late MockMyStudioCubit myStudioCubit;
  late StudioRegistrationCoordinator coordinator;

  final draft = StudioRegistrationDraft(
    email: ' owner@example.com ',
    password: 'secret123',
    name: ' Sala Norte ',
    businessName: ' North Studios S.L. ',
    cif: ' B12345678 ',
    description: ' Sala amplia ',
    address: ' Calle 1 ',
    phone: ' +34 123 456 ',
    vatNumber: ' ES12345678A ',
    licenseNumber: ' LIC-001 ',
    openingHours: const {'lun': '09:00-18:00'},
    city: ' Madrid ',
    province: ' Madrid ',
    postalCode: ' 28001 ',
    maxRoomCapacity: 50,
    accessibilityInfo: ' Acceso adaptado ',
    noiseOrdinanceCompliant: true,
    insuranceExpiry: DateTime(2027, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      StudioEntity(
        id: 'studio-id',
        ownerId: 'owner-id',
        name: 'name',
        businessName: 'businessName',
        cif: 'cif',
        description: 'description',
        address: 'address',
        contactEmail: 'email@example.com',
        contactPhone: '000',
        vatNumber: 'ES00000000X',
        licenseNumber: 'LIC-000',
        openingHours: const {},
        city: 'Test',
        province: 'Test',
        postalCode: '00000',
        maxRoomCapacity: 0,
        accessibilityInfo: '',
        noiseOrdinanceCompliant: false,
        insuranceExpiry: DateTime(2027, 1, 1),
      ),
    );
  });

  setUp(() {
    authCubit = MockAuthCubit();
    myStudioCubit = MockMyStudioCubit();
    coordinator = StudioRegistrationCoordinator(idGenerator: () => 'studio-1');

    when(
      () => authCubit.register(
        email: any(named: 'email'),
        password: any(named: 'password'),
        displayName: any(named: 'displayName'),
      ),
    ).thenAnswer((_) async {});

    when(() => myStudioCubit.createStudio(any())).thenAnswer((_) async {});
  });

  test('submitRegistration delegates to AuthCubit.register', () {
    coordinator.submitRegistration(authCubit: authCubit, draft: draft);

    verify(
      () => authCubit.register(
        email: 'owner@example.com',
        password: 'secret123',
        displayName: 'Sala Norte',
      ),
    ).called(1);
  });

  test('createStudio delegates to MyStudioCubit.createStudio', () {
    coordinator.createStudio(
      myStudioCubit: myStudioCubit,
      ownerId: 'owner-1',
      draft: draft,
    );

    final captured =
        verify(() => myStudioCubit.createStudio(captureAny())).captured.single
            as StudioEntity;

    expect(captured.id, 'studio-1');
    expect(captured.ownerId, 'owner-1');
    expect(captured.name, 'Sala Norte');
    expect(captured.businessName, 'North Studios S.L.');
    expect(captured.cif, 'B12345678');
    expect(captured.description, 'Sala amplia');
    expect(captured.address, 'Calle 1');
    expect(captured.contactEmail, 'owner@example.com');
    expect(captured.contactPhone, '+34 123 456');
    expect(captured.vatNumber, 'ES12345678A');
    expect(captured.licenseNumber, 'LIC-001');
    expect(captured.openingHours, {'lun': '09:00-18:00'});
    expect(captured.city, 'Madrid');
    expect(captured.province, 'Madrid');
    expect(captured.postalCode, '28001');
    expect(captured.maxRoomCapacity, 50);
    expect(captured.accessibilityInfo, 'Acceso adaptado');
    expect(captured.noiseOrdinanceCompliant, true);
    expect(captured.insuranceExpiry, DateTime(2027, 1, 1));
  });
}
