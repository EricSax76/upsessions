import { admin } from '../firebase';
import { region } from '../region';

import { primaryRoleFrom, resolveRoles } from './roles';
import { record, stringOrEmpty } from './shared';

async function syncUserRoles(uid: string): Promise<void> {
  if (!uid) return;
  const roles = await resolveRoles(uid, null);
  const primaryRole = primaryRoleFrom(roles);
  await admin.firestore().collection('users').doc(uid).set(
    {
      role: primaryRole,
      roles,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

export const onEventManagerWriteSyncUserRole = region.firestore
  .document('event_managers/{managerId}')
  .onWrite(async (change, context) => {
    const before = record(change.before.data());
    const after = record(change.after.data());
    const managerId = stringOrEmpty(context.params.managerId).trim();
    const beforeOwnerId = stringOrEmpty(before.ownerId).trim();
    const afterOwnerId = stringOrEmpty(after.ownerId).trim();

    const userIds = new Set<string>();
    if (managerId) {
      userIds.add(managerId);
    }
    if (beforeOwnerId) {
      userIds.add(beforeOwnerId);
    }
    if (afterOwnerId) {
      userIds.add(afterOwnerId);
    }

    await Promise.all(Array.from(userIds.values()).map((uid) => syncUserRoles(uid)));
  });
