import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/studios/models/studio_entity.dart';
import 'package:upsessions/modules/studios/ui/forms/studio_form_draft.dart';
import 'package:upsessions/modules/studios/ui/forms/studio_form_validator.dart';

StudioEntity _studioFixture() {
  return StudioEntity(
    id: 'studio-1',
    ownerId: 'owner-1',
    name: 'Studio Name',
    description: 'Desc',
    address: 'Address 1',
    contactEmail: 'studio@test.com',
    contactPhone: '123456789',
    cif: 'CIF-1',
    businessName: 'Business',
    vatNumber: 'VAT-1',
    licenseNumber: 'LIC-1',
    openingHours: const {'lun': '09:00-18:00', 'vie': '10:00-20:00'},
    city: 'Madrid',
    province: 'Madrid',
    postalCode: '28001',
    maxRoomCapacity: 20,
    accessibilityInfo: 'Ramp access',
    noiseOrdinanceCompliant: true,
    insuranceExpiry: DateTime(2030, 1, 1),
  );
}

void main() {
  group('StudioFormDraft', () {
    test('fillFromStudio hydrates fields and openingHours', () {
      final draft = StudioFormDraft();
      addTearDown(draft.dispose);

      final studio = _studioFixture();
      draft.fillFromStudio(studio);

      expect(draft.nameController.text, studio.name);
      expect(draft.businessNameController.text, studio.businessName);
      expect(draft.maxRoomCapacityController.text, '20');
      expect(draft.noiseOrdinanceCompliant, isTrue);
      expect(draft.insuranceExpiry, studio.insuranceExpiry);
      expect(draft.openingHoursControllers['lun']?.text, '09:00-18:00');
      expect(draft.openingHoursControllers['mar']?.text, isEmpty);
    });

    test('buildOpeningHours excludes empty entries', () {
      final draft = StudioFormDraft();
      addTearDown(draft.dispose);

      draft.openingHoursControllers['lun']?.text = '09:00-18:00';
      draft.openingHoursControllers['mar']?.text = '   ';

      expect(draft.buildOpeningHours(), {'lun': '09:00-18:00'});
    });

    test('applyToExisting keeps fallback max capacity when invalid', () {
      final draft = StudioFormDraft();
      addTearDown(draft.dispose);

      final studio = _studioFixture();
      draft.fillFromStudio(studio);
      draft.maxRoomCapacityController.text = '0';

      final updated = draft.applyToExisting(studio);
      expect(updated.maxRoomCapacity, studio.maxRoomCapacity);
    });
  });

  group('StudioFormValidator', () {
    test('required validates non-empty values', () {
      expect(StudioFormValidator.required('x'), isNull);
      expect(StudioFormValidator.required('  '), 'Required');
    });

    test('positiveInt validates format and positivity', () {
      expect(StudioFormValidator.positiveInt('1'), isNull);
      expect(
        StudioFormValidator.positiveInt('0'),
        'Must be an integer greater than 0',
      );
      expect(
        StudioFormValidator.positiveInt('abc'),
        'Must be an integer greater than 0',
      );
    });
  });
}
