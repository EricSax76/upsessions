import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/venues/models/venue_entity.dart';
import 'package:upsessions/modules/venues/ui/forms/venue_form_draft.dart';
import 'package:upsessions/modules/venues/ui/forms/venue_form_validator.dart';

VenueEntity _venueFixture() {
  return VenueEntity(
    id: 'venue-1',
    ownerId: 'owner-1',
    name: 'Sala Centro',
    description: 'Desc',
    address: 'Calle 1',
    city: 'Madrid',
    province: 'Madrid',
    postalCode: '28001',
    contactEmail: 'venue@test.com',
    contactPhone: '+34 600 000 001',
    licenseNumber: 'LIC-1',
    maxCapacity: 120,
    accessibilityInfo: 'Ramp access',
    isPublic: false,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 2, 1),
  );
}

void main() {
  group('VenueFormDraft', () {
    test('fillFromVenue hydrates text controllers', () {
      final draft = VenueFormDraft();
      addTearDown(draft.dispose);

      final venue = _venueFixture();
      draft.fillFromVenue(venue);

      expect(draft.nameController.text, venue.name);
      expect(draft.cityController.text, venue.city);
      expect(draft.postalCodeController.text, '28001');
      expect(draft.maxCapacityController.text, '120');
    });

    test('toVenueEntity trims values and preserves editing metadata', () {
      final draft = VenueFormDraft();
      addTearDown(draft.dispose);

      final existing = _venueFixture();
      draft.nameController.text = '  Sala Nueva  ';
      draft.descriptionController.text = '  Desc nueva  ';
      draft.addressController.text = '  Calle 2  ';
      draft.cityController.text = '  Valencia ';
      draft.provinceController.text = ' Valencia  ';
      draft.postalCodeController.text = '   ';
      draft.contactEmailController.text = '  nueva@test.com  ';
      draft.contactPhoneController.text = ' +34 600 000 009 ';
      draft.licenseNumberController.text = ' LIC-9 ';
      draft.maxCapacityController.text = ' 200 ';
      draft.accessibilityInfoController.text = ' Elevador ';

      final entity = draft.toVenueEntity(
        ownerId: 'manager-9',
        isPublic: true,
        initialVenue: existing,
      );

      expect(entity.id, existing.id);
      expect(entity.ownerId, 'manager-9');
      expect(entity.name, 'Sala Nueva');
      expect(entity.description, 'Desc nueva');
      expect(entity.address, 'Calle 2');
      expect(entity.city, 'Valencia');
      expect(entity.province, 'Valencia');
      expect(entity.postalCode, isNull);
      expect(entity.contactEmail, 'nueva@test.com');
      expect(entity.contactPhone, '+34 600 000 009');
      expect(entity.licenseNumber, 'LIC-9');
      expect(entity.maxCapacity, 200);
      expect(entity.accessibilityInfo, 'Elevador');
      expect(entity.isPublic, isTrue);
      expect(entity.isActive, existing.isActive);
      expect(entity.createdAt, existing.createdAt);
      expect(entity.updatedAt, existing.updatedAt);
    });

    test('toVenueEntity falls back to 0 when capacity is invalid', () {
      final draft = VenueFormDraft();
      addTearDown(draft.dispose);

      draft.maxCapacityController.text = 'abc';
      final entity = draft.toVenueEntity(
        ownerId: 'owner-1',
        isPublic: true,
        initialVenue: null,
      );

      expect(entity.maxCapacity, 0);
    });
  });

  group('VenueFormValidator', () {
    test('required validates non-empty values', () {
      expect(VenueFormValidator.required('x'), isNull);
      expect(VenueFormValidator.required('  '), 'Requerido');
    });

    test('email validates basic address format', () {
      expect(VenueFormValidator.email('venue@test.com'), isNull);
      expect(VenueFormValidator.email(''), 'Requerido');
      expect(VenueFormValidator.email('invalid'), 'Email no válido');
      expect(VenueFormValidator.email('@domain.com'), 'Email no válido');
    });

    test('positiveInt validates number and parsePositiveInt parses it', () {
      expect(VenueFormValidator.positiveInt('1'), isNull);
      expect(VenueFormValidator.positiveInt('0'), 'Debe ser un entero > 0');
      expect(VenueFormValidator.positiveInt('abc'), 'Debe ser un entero > 0');
      expect(VenueFormValidator.parsePositiveInt('20'), 20);
      expect(VenueFormValidator.parsePositiveInt(' 0 '), isNull);
    });
  });
}
