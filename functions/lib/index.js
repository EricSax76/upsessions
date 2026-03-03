"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onChatThreadWrite = exports.onGroupInviteUsedCreateContacts = exports.onGroupInviteCreated = exports.ping = exports.updateUserComplianceProfile = exports.syncUserSession = exports.onAuthUserDeleteSoftDelete = exports.onAuthUserCreateBootstrap = exports.acceptLegalDocs = exports.acceptLegalBundle = exports.resolveSpotifyArtistImages = exports.seedChatThreads = void 0;
const firebase_1 = require("./firebase");
const region_1 = require("./region");
var chatSeeder_1 = require("./chatSeeder");
Object.defineProperty(exports, "seedChatThreads", { enumerable: true, get: function () { return chatSeeder_1.seedChatThreads; } });
var spotify_artist_images_1 = require("./spotify_artist_images");
Object.defineProperty(exports, "resolveSpotifyArtistImages", { enumerable: true, get: function () { return spotify_artist_images_1.resolveSpotifyArtistImages; } });
var legalCompliance_1 = require("./legalCompliance");
Object.defineProperty(exports, "acceptLegalBundle", { enumerable: true, get: function () { return legalCompliance_1.acceptLegalBundle; } });
Object.defineProperty(exports, "acceptLegalDocs", { enumerable: true, get: function () { return legalCompliance_1.acceptLegalDocs; } });
Object.defineProperty(exports, "onAuthUserCreateBootstrap", { enumerable: true, get: function () { return legalCompliance_1.onAuthUserCreateBootstrap; } });
Object.defineProperty(exports, "onAuthUserDeleteSoftDelete", { enumerable: true, get: function () { return legalCompliance_1.onAuthUserDeleteSoftDelete; } });
Object.defineProperty(exports, "syncUserSession", { enumerable: true, get: function () { return legalCompliance_1.syncUserSession; } });
Object.defineProperty(exports, "updateUserComplianceProfile", { enumerable: true, get: function () { return legalCompliance_1.updateUserComplianceProfile; } });
function stringList(value) {
    if (!Array.isArray(value))
        return [];
    return value.map((entry) => String(entry)).filter(Boolean);
}
function stringOrEmpty(value) {
    return typeof value === 'string' ? value : '';
}
function numberOrNull(value) {
    return typeof value === 'number' && Number.isFinite(value) ? value : null;
}
function nonNegativeInt(value) {
    const resolved = numberOrNull(value);
    if (resolved == null)
        return 0;
    return Math.max(0, Math.floor(resolved));
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
function contactPayloadFromMusician(contactId, musicianData) {
    const styles = stringList(musicianData.styles);
    const highlightStyle = stringOrEmpty(musicianData.highlightStyle);
    const resolvedHighlightStyle = highlightStyle || (styles.length ? styles[0] : null);
    const photoUrl = stringOrEmpty(musicianData.photoUrl);
    return {
        id: contactId,
        ownerId: stringOrEmpty(musicianData.ownerId) || contactId,
        name: stringOrEmpty(musicianData.name) || 'Musician',
        instrument: stringOrEmpty(musicianData.instrument),
        city: stringOrEmpty(musicianData.city),
        styles,
        highlightStyle: resolvedHighlightStyle,
        photoUrl: photoUrl || null,
        experienceYears: nonNegativeInt(musicianData.experienceYears),
        rating: numberOrNull(musicianData.rating),
        updatedAt: firebase_1.admin.firestore.FieldValue.serverTimestamp(),
    };
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
    const db = firebase_1.admin.firestore();
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
        createdAt: firebase_1.admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: firebase_1.admin.firestore.FieldValue.serverTimestamp(),
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
    const response = await firebase_1.admin.messaging().sendEachForMulticast(payload);
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
exports.onGroupInviteUsedCreateContacts = region_1.region.firestore
    .document('groups/{groupId}/invites/{inviteId}')
    .onUpdate(async (change) => {
    const before = change.before.data() ?? {};
    const after = change.after.data() ?? {};
    const beforeStatus = stringOrEmpty(before.status);
    const afterStatus = stringOrEmpty(after.status);
    if (beforeStatus === 'used' || afterStatus !== 'used') {
        return;
    }
    const inviterUid = stringOrEmpty(after.createdBy);
    const targetUid = stringOrEmpty(after.targetUid);
    const usedByUid = stringOrEmpty(after.usedBy);
    const acceptedUid = usedByUid || targetUid;
    if (!inviterUid || !acceptedUid || inviterUid === acceptedUid) {
        return;
    }
    const db = firebase_1.admin.firestore();
    const [inviterMusicianSnap, acceptedMusicianSnap] = await Promise.all([
        db.collection('musicians').doc(inviterUid).get(),
        db.collection('musicians').doc(acceptedUid).get(),
    ]);
    const inviterPayload = contactPayloadFromMusician(inviterUid, record(inviterMusicianSnap.data()));
    const acceptedPayload = contactPayloadFromMusician(acceptedUid, record(acceptedMusicianSnap.data()));
    await Promise.all([
        db
            .collection('musicians')
            .doc(inviterUid)
            .collection('contacts')
            .doc(acceptedUid)
            .set(acceptedPayload, { merge: true }),
        db
            .collection('musicians')
            .doc(acceptedUid)
            .collection('contacts')
            .doc(inviterUid)
            .set(inviterPayload, { merge: true }),
    ]);
});
exports.onChatThreadWrite = region_1.region.firestore
    .document('chat_threads/{threadId}')
    .onWrite(async (change, context) => {
    const threadId = String(context.params.threadId ?? '');
    if (!threadId) {
        return;
    }
    const db = firebase_1.admin.firestore();
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
            ?? firebase_1.admin.firestore.FieldValue.serverTimestamp(),
        createdAt: sourceData.createdAt
            ?? firebase_1.admin.firestore.FieldValue.serverTimestamp(),
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