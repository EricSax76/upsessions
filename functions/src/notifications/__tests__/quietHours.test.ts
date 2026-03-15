import { isQuiet, parseQuietHours } from '../quietHours';

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

void (() => {
  const parsed = parseQuietHours({
    quietHours: {
      enabled: true,
      startHour: 22,
      endHour: 8,
      timezone: 'Europe/Madrid',
    },
  });

  assert(parsed !== null, 'Expected quietHours to parse');
  assert(parsed?.timezone === 'Europe/Madrid', 'Expected timezone to be preserved');

  const nowUtc = new Date(Date.UTC(2026, 0, 15, 21, 30)); // 22:30 in Madrid.
  assert(
    parsed != null && isQuiet(parsed, nowUtc),
    'Expected quiet-hours to be active for 22-8 at 22:30 local time',
  );

  const invalidTimezone = parseQuietHours({
    quietHours: {
      enabled: true,
      startHour: 22,
      endHour: 8,
      timezone: 'Invalid/Timezone',
    },
  });
  assert(invalidTimezone !== null, 'Invalid timezone should still parse');

  const utcLateHour = new Date(Date.UTC(2026, 0, 15, 23, 0));
  assert(
    invalidTimezone != null && isQuiet(invalidTimezone, utcLateHour),
    'Invalid timezone must fall back to UTC hour',
  );

  const malformed = parseQuietHours({
    quietHours: { enabled: true, startHour: 99, endHour: 8 },
  });
  assert(malformed === null, 'Malformed quietHours should return null');
})();
