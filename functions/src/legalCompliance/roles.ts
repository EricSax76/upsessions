import * as functions from 'firebase-functions';

import { admin } from '../firebase';

import { DEFAULT_ROLE } from './constants';
import { record, stringOrEmpty } from './shared';
import type { UserRole } from './types';

function normalizeRole(rawRole: string): UserRole {
  const role = rawRole.trim().toLowerCase();
  if (!role) return DEFAULT_ROLE;
  if (role === 'eventmanager' || role === 'manager') return 'event_manager';
  if (role === 'event_manager') return 'event_manager';
  if (role === 'studio') return 'studio';
  if (role === 'admin') return 'admin';
  if (role === 'musician') return 'musician';
  return DEFAULT_ROLE;
}

export function tokenRole(context: functions.https.CallableContext): UserRole | null {
  const token = record(context.auth?.token);
  const rawRole = stringOrEmpty(token.role).trim();
  if (!rawRole) return null;
  return normalizeRole(rawRole);
}

export function primaryRoleFrom(roles: UserRole[]): UserRole {
  if (roles.includes('admin')) return 'admin';
  if (roles.length <= 1) return roles[0] ?? DEFAULT_ROLE;
  return 'multi';
}

export async function resolveRoles(uid: string, hintedRole: UserRole | null): Promise<UserRole[]> {
  const db = admin.firestore();
  const [managerDoc, studioDocs, musicianDoc, musicianByOwnerId] = await Promise.all([
    db.collection('event_managers').doc(uid).get(),
    db.collection('studios').where('ownerId', '==', uid).limit(1).get(),
    db.collection('musicians').doc(uid).get(),
    db.collection('musicians').where('ownerId', '==', uid).limit(1).get(),
  ]);

  const roles = new Set<UserRole>();
  if (hintedRole != null) {
    roles.add(hintedRole);
  }
  if (managerDoc.exists) {
    roles.add('event_manager');
  }
  if (!studioDocs.empty) {
    roles.add('studio');
  }
  if (musicianDoc.exists || !musicianByOwnerId.empty) {
    roles.add('musician');
  }
  if (!roles.size) {
    roles.add(DEFAULT_ROLE);
  }

  return Array.from(roles.values());
}
