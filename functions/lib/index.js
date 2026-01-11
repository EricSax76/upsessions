"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onChatThreadWrite = exports.onGroupInviteCreated = exports.ping = exports.seedChatThreads = void 0;
const admin = require("firebase-admin");
const region_1 = require("./region");
var chatSeeder_1 = require("./chatSeeder");
Object.defineProperty(exports, "seedChatThreads", { enumerable: true, get: function () { return chatSeeder_1.seedChatThreads; } });
admin.initializeApp();
function stringList(value) {
    if (!Array.isArray(value))
        return [];
    return value.map((entry) => String(entry)).filter(Boolean);
}
function record(value) {
    if (value == null)
        return {};
    if (typeof value !== 'object')
        return {};
    if (Array.isArray(value))
        return {};
    return value;
}
exports.ping = region_1.region.https.onRequest((request, response) => {
    response.send('Solomusicos Functions are alive!');
});
exports.onGroupInviteCreated = region_1.region.firestore
    .document('groups/{groupId}/invites/{inviteId}')
    .onCreate(async (snapshot, context) => {
    const data = snapshot.data() ?? {};
    const groupId = context.params.groupId;
    const inviteId = context.params.inviteId;
    const targetUid = String(data.targetUid ?? '');
    const createdBy = String(data.createdBy ?? '');
    if (!targetUid) {
        return;
    }
    const db = admin.firestore();
    const groupSnap = await db.collection('groups').doc(groupId).get();
    const groupData = groupSnap.data() ?? {};
    const groupName = String(groupData.name ?? 'Grupo');
    const inviteDocRef = db
        .collection('musicians')
        .doc(targetUid)
        .collection('invites')
        .doc(inviteId);
    await inviteDocRef.set({
        type: 'group_invite',
        groupId,
        groupName,
        inviteId,
        createdBy,
        status: 'pending',
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    const tokensSnap = await db
        .collection('musicians')
        .doc(targetUid)
        .collection('fcmTokens')
        .get();
    const tokens = tokensSnap.docs.map((doc) => doc.id).filter(Boolean);
    if (!tokens.length) {
        return;
    }
    const payload = {
        tokens,
        notification: {
            title: 'Invitación a grupo',
            body: `Te invitaron a ${groupName}`,
        },
        data: {
            type: 'group_invite',
            groupId,
            inviteId,
        },
    };
    const response = await admin.messaging().sendEachForMulticast(payload);
    const invalidTokens = [];
    response.responses.forEach((res, idx) => {
        if (!res.success) {
            const code = res.error?.code ?? '';
            if (code === 'messaging/invalid-registration-token'
                || code === 'messaging/registration-token-not-registered') {
                invalidTokens.push(tokens[idx]);
            }
        }
    });
    await Promise.all(invalidTokens.map((token) => db
        .collection('musicians')
        .doc(targetUid)
        .collection('fcmTokens')
        .doc(token)
        .delete()));
});
exports.onChatThreadWrite = region_1.region.firestore
    .document('chat_threads/{threadId}')
    .onWrite(async (change, context) => {
    const threadId = String(context.params.threadId ?? '');
    if (!threadId) {
        return;
    }
    const db = admin.firestore();
    const afterExists = change.after.exists;
    const afterData = change.after.data() ?? {};
    const beforeData = change.before.data() ?? {};
    const sourceData = afterExists ? afterData : beforeData;
    const participants = stringList(sourceData.participants);
    if (!participants.length) {
        return;
    }
    if (!afterExists) {
        await Promise.all(participants.map((uid) => db
            .collection('musicians')
            .doc(uid)
            .collection('threads')
            .doc(threadId)
            .delete()
            .catch(() => null)));
        return;
    }
    const payload = {
        participants: stringList(sourceData.participants),
        participantLabels: record(sourceData.participantLabels),
        lastMessage: record(sourceData.lastMessage),
        lastMessageAt: sourceData.lastMessageAt
            ?? sourceData.createdAt
            ?? admin.firestore.FieldValue.serverTimestamp(),
        createdAt: sourceData.createdAt
            ?? admin.firestore.FieldValue.serverTimestamp(),
        unreadCounts: record(sourceData.unreadCounts),
    };
    await Promise.all(participants.map((uid) => db
        .collection('musicians')
        .doc(uid)
        .collection('threads')
        .doc(threadId)
        .set(payload, { merge: true })));
});
//# sourceMappingURL=index.js.map