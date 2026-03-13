import { admin } from '../../firebase';
import { validateStudioData } from '../onStudioWrite';

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function buildValidStudioData(): Record<string, unknown> {
  return {
    name: 'Sala Norte',
    cif: 'B12345674',
    businessName: 'Sala Norte SL',
    city: 'Madrid',
    province: 'Madrid',
    postalCode: '28001',
    vatNumber: 'ESB12345674',
    licenseNumber: 'LIC-001',
    contactEmail: 'studio@example.com',
    contactPhone: '+34123456789',
    accessibilityInfo: 'Acceso adaptado',
    maxRoomCapacity: 30,
    noiseOrdinanceCompliant: true,
    insuranceExpiry: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 24 * 60 * 60 * 1000),
    ),
    openingHours: {
      lun: '09:00-18:00',
    },
  };
}

void (async () => {
  const validErrors = validateStudioData(buildValidStudioData());
  assert(
    validErrors.length === 0,
    `Expected valid studio data to pass, got: ${validErrors.join(', ')}`,
  );

  const invalidCifErrors = validateStudioData({
    ...buildValidStudioData(),
    cif: 'INVALID-CIF',
  });
  assert(
    invalidCifErrors.some((error) => error.includes('cif')),
    `Expected invalid CIF error, got: ${invalidCifErrors.join(', ')}`,
  );

  const expiredInsuranceErrors = validateStudioData({
    ...buildValidStudioData(),
    insuranceExpiry: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 24 * 60 * 60 * 1000),
    ),
  });
  assert(
    expiredInsuranceErrors.some((error) => error.includes('insuranceExpiry')),
    `Expected expired insurance error, got: ${expiredInsuranceErrors.join(', ')}`,
  );
})();
