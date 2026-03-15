import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/venues/ui/forms/venue_register_validator.dart';

void main() {
  group('VenueRegisterValidator', () {
    test('required validates non-empty values', () {
      expect(VenueRegisterValidator.required('x'), isNull);
      expect(VenueRegisterValidator.required('  '), 'Requerido');
    });

    test('email validates basic format', () {
      expect(VenueRegisterValidator.email('venue@test.com'), isNull);
      expect(VenueRegisterValidator.email(''), 'Requerido');
      expect(VenueRegisterValidator.email('invalid'), 'Correo inválido');
      expect(VenueRegisterValidator.email('@domain.com'), 'Correo inválido');
      expect(VenueRegisterValidator.email('name@'), 'Correo inválido');
    });

    test('password validates minimum length', () {
      expect(VenueRegisterValidator.password('123456'), isNull);
      expect(VenueRegisterValidator.password('12345'), 'Mínimo 6 caracteres');
      expect(VenueRegisterValidator.password(null), 'Mínimo 6 caracteres');
    });
  });
}
