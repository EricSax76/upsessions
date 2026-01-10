import type { Request, Response } from 'firebase-functions';
import type { DocumentData } from 'firebase-admin/firestore';

import { admin, db } from './firebase';
import { region } from './region';

type ThreadPayload = {
  id?: string;
  participants?: unknown;
  participantLabels?: Record<string, string>;
  unreadCounts?: Record<string, unknown>;
  createdAt?: unknown;
  messages?: Array<Record<string, unknown>>;
  lastMessage?: Record<string, unknown>;
  lastMessageAt?: unknown;
};

const isNonEmptyString = (value: unknown): value is string =>
  typeof value === 'string' && value.trim().length > 0;

const ensureParticipants = (value: unknown): string[] => {
  const candidates =
    Array.isArray(value) ? value : typeof value === 'string' ? [value] : [];
  return candidates
    .map((entry) => (entry ?? '').toString().trim())
    .filter((entry) => entry.length > 0);
};

const toTimestamp = (
  value?: unknown,
  fallback?: admin.firestore.Timestamp,
): admin.firestore.Timestamp => {
  if (value instanceof admin.firestore.Timestamp) {
    return value;
  }
  if (typeof value === 'number') {
    return admin.firestore.Timestamp.fromMillis(value);
  }
  if (typeof value === 'string') {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.valueOf())) {
      return admin.firestore.Timestamp.fromDate(parsed);
    }
  }
  return fallback ?? admin.firestore.Timestamp.now();
};

const normalizeMessagePayload = (
  message: DocumentData,
  sentAt: admin.firestore.Timestamp,
): DocumentData => ({
  sender:
    message.sender ??
    message.senderEmail ??
    message.senderId ??
    '',
  senderId: message.senderId ?? '',
  senderEmail: message.senderEmail ?? '',
  body: message.body ?? '',
  sentAt,
});

export const seedChatThreads = region.https.onRequest(
  async (request: Request, response: Response) => {
    if (request.method !== 'POST') {
      response.set('Allow', 'POST');
      response.status(405).send('Use POST to seed chat threads.');
      return;
    }

    const payload = request.body ?? {};
    if (!Array.isArray(payload.threads)) {
      response.status(400).send('Missing "threads" array in the request body.');
      return;
    }

    const results: Array<{ threadId: string; status: string }> = [];

    try {
      for (const rawThread of payload.threads as ThreadPayload[]) {
        const participants = ensureParticipants(rawThread.participants);
        if (participants.length === 0) {
          results.push({
            threadId: '',
            status: 'skipped: no participants provided',
          });
          continue;
        }

        const threadId = isNonEmptyString(rawThread.id)
          ? rawThread.id!.trim()
          : undefined;
        const threadRef = threadId
          ? db.collection('chat_threads').doc(threadId)
          : db.collection('chat_threads').doc();

        const createdAt = toTimestamp(rawThread.createdAt);

        await threadRef.set(
          {
            participants,
            participantLabels: rawThread.participantLabels ?? {},
            createdAt,
            unreadCounts: rawThread.unreadCounts ?? {},
          },
          { merge: true },
        );

        const messageEntries = Array.isArray(rawThread.messages)
          ? rawThread.messages
          : [];
        if (messageEntries.length === 0 && rawThread.lastMessage) {
          messageEntries.push(rawThread.lastMessage);
        }
        if (messageEntries.length === 0) {
          messageEntries.push({
            sender: participants[0],
            senderId: participants[0],
            senderEmail: '',
            body: '',
            sentAt: createdAt,
          });
        }

        const messagesCollection = threadRef.collection('messages');
        let lastMessageWritten: DocumentData | null = null;

        for (const entry of messageEntries) {
          const messageTimestamp = toTimestamp(entry?.sentAt, createdAt);
          const messageId = isNonEmptyString(entry?.id)
            ? entry!.id!.trim()
            : undefined;
          const messageRef = messageId
            ? messagesCollection.doc(messageId)
            : messagesCollection.doc();
          const messagePayload = normalizeMessagePayload(
            entry ?? {},
            messageTimestamp,
          );
          await messageRef.set(messagePayload);
          lastMessageWritten = { ...messagePayload, id: messageRef.id };
        }

        const lastMessageSentAt = toTimestamp(
          rawThread.lastMessageAt,
          lastMessageWritten?.sentAt ?? createdAt,
        );
        const lastMessageSource =
          rawThread.lastMessage ?? lastMessageWritten ?? {
            sender: participants[0],
            senderId: participants[0],
            senderEmail: '',
            body: '',
          };
        const normalizedLastMessage = normalizeMessagePayload(
          lastMessageSource,
          lastMessageSentAt,
        );
        const lastMessageIdCandidate = rawThread.lastMessage?.id;
        const finalLastMessage: DocumentData = {
          ...normalizedLastMessage,
          id: isNonEmptyString(lastMessageIdCandidate)
            ? lastMessageIdCandidate!.trim()
            : lastMessageWritten?.id ?? '',
        };

        await threadRef.set(
          {
            lastMessage: finalLastMessage,
            lastMessageAt: finalLastMessage.sentAt,
          },
          { merge: true },
        );

        results.push({ threadId: threadRef.id, status: 'created' });
      }

      response.status(200).json({ seeded: results });
      return;
    } catch (error) {
      console.error('Chat seeding failed', error);
      response.status(500).send(
        `Seeding failed: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  },
);
