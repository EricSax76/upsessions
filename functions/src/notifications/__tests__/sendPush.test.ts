import { SCENARIO_KEYS } from '../scenarioKeys';
import { isScenarioPushEnabled, toFcmData } from '../sendPush';

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

void (() => {
  assert(
    isScenarioPushEnabled({}, SCENARIO_KEYS.studioBookingPending),
    'Missing preferences must default to push-enabled',
  );

  assert(
    !isScenarioPushEnabled({}, SCENARIO_KEYS.studioBookingConfirmed),
    'Scenarios without push channel must never dispatch push',
  );

  assert(
    !isScenarioPushEnabled(
      {
        scenarios: {
          [SCENARIO_KEYS.studioBookingPending]: { push: false },
        },
      },
      SCENARIO_KEYS.studioBookingPending,
    ),
    'Scenario push=false must disable dispatch',
  );

  assert(
    isScenarioPushEnabled({}, SCENARIO_KEYS.venueJamSessionScheduled),
    'Venue jam scenarios should allow push by default',
  );

  const payload = toFcmData(SCENARIO_KEYS.managerRequestAccepted, {
    type: 'manager_request',
    requestId: 'req-1',
    status: 'accepted',
    retries: 2,
    debug: true,
  });

  assert(
    payload.scenarioKey === SCENARIO_KEYS.managerRequestAccepted,
    'FCM payload must include scenarioKey',
  );
  assert(payload.retries === '2', 'Numeric values must be stringified');
  assert(payload.debug === 'true', 'Boolean values must be stringified');
})();
