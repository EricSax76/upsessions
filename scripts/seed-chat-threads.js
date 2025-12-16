#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const [, , inputFile] = process.argv;

const configPath =
  inputFile && typeof inputFile === 'string'
    ? path.resolve(process.cwd(), inputFile)
    : path.resolve(__dirname, 'test-chat.json');

if (!fs.existsSync(configPath)) {
  console.error(`No se encontró el archivo de datos en ${configPath}`);
  process.exit(1);
}

const payload = JSON.parse(fs.readFileSync(configPath, 'utf8'));

const threads = Array.isArray(payload.threads) ? payload.threads : [];

const isNonEmptyString = (value) => typeof value === 'string' && value.trim().length > 0;

const ensureParticipants = (value) => {
  const candidates = Array.isArray(value) ? value : typeof value === 'string' ? [value] : [];
  return candidates
    .map((entry) => (entry ?? '').toString().trim())
    .filter((entry) => entry.length > 0);
};

const toTimestamp = (value, fallback) => {
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

const normalizeMessagePayload = (message, defaultTimestamp) => {
  const sentAt = toTimestamp(message.sentAt, defaultTimestamp);
  return {
    senderId: message.senderId ?? message.sender ?? '',
    body: message.body ?? '',
    sentAt,
  };
};
const seedThread = async (raw) => {
  const participants = ensureParticipants(raw.participants);
  if (participants.length === 0) {
    return { id: '', status: 'omitido: sin participantes' };
  }

  const threadId = isNonEmptyString(raw.id) ? raw.id.trim() : undefined;
  const docRef = threadId ? db.collection('chat_threads').doc(threadId) : db.collection('chat_threads').doc();
  const createdAt = toTimestamp(raw.createdAt);
  
  const messageEntries = Array.isArray(raw.messages) ? raw.messages : [];
  const messagesCollection = docRef.collection('messages');
  const batch = db.batch();
  let lastMessagePayload = null;

  for (const entry of messageEntries) {
    const messageId = isNonEmptyString(entry.id) ? entry.id.trim() : undefined;
    const messageRef = messageId ? messagesCollection.doc(messageId) : messagesCollection.doc();
    const messagePayload = normalizeMessagePayload(entry, createdAt);
    batch.set(messageRef, messagePayload);
    lastMessagePayload = messagePayload;
  }

  if (!lastMessagePayload && participants.length > 0) {
    // Si no hay mensajes, crea uno vacío para que el hilo no esté incompleto
    lastMessagePayload = {
      senderId: participants[0],
      body: 'Hilo iniciado.',
      sentAt: createdAt,
    };
    const messageRef = messagesCollection.doc();
    batch.set(messageRef, lastMessagePayload);
  }

  const threadData = {
    participants,
    participantLabels: raw.participantLabels ?? {},
    createdAt,
    unreadCounts: raw.unreadCounts ?? {},
    lastMessage: lastMessagePayload,
    lastMessageAt: lastMessagePayload?.sentAt ?? createdAt,
  };

  batch.set(docRef, threadData, { merge: true });

  await batch.commit();
  /*
  await docRef.set(
    {
      lastMessage: finalLastMessage,
      lastMessageAt: finalLastMessage.sentAt,
    },
    { merge: true },
  );
  */

  return { id: docRef.id, status: 'creado' };
};

const run = async () => {
  if (threads.length === 0) {
    console.warn('No se encontraron threads en el archivo de configuración.');
    return;
  }
  console.log(`Sembrando ${threads.length} hilos desde ${configPath}`);
  const results = [];
  for (const thread of threads) {
    results.push(await seedThread(thread));
  }
  console.table(results);
};

run()
  .then(() => {
    console.log('Seed completado.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Seed fallido:', error);
    process.exit(1);
  });
