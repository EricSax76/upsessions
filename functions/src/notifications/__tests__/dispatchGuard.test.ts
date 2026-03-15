import { buildDispatchDocId } from '../dispatchGuard';
import { SCENARIO_KEYS } from '../scenarioKeys';

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

void (() => {
  const docId = buildDispatchDocId({
    eventId: 'invite/abc.123',
    uid: 'user.42',
    scenarioKey: SCENARIO_KEYS.musicianGroupInvite,
  });

  assert(
    docId === 'musician_group_invite_user_42_invite_abc_123',
    `Unexpected docId sanitization: ${docId}`,
  );

  const another = buildDispatchDocId({
    eventId: 'invite/abc.123',
    uid: 'another',
    scenarioKey: SCENARIO_KEYS.musicianGroupInvite,
  });
  assert(docId !== another, 'Dispatch doc ids must include recipient uid');
})();
