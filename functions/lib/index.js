"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.seedChatThreads = exports.onGroupInviteCreated = exports.ping = void 0;
const admin = require("firebase-admin");
const region_1 = require("./region");
admin.initializeApp();
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
var chatSeeder_1 = require("./chatSeeder");
Object.defineProperty(exports, "seedChatThreads", { enumerable: true, get: function () { return chatSeeder_1.seedChatThreads; } });
//# sourceMappingURL=index.js.map