import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_firestore_mapper.dart';
import 'chat_contact_policy.dart';
import 'chat_repository_base.dart';
import '../models/chat_actor_kind.dart';
import '../models/chat_message.dart';
import '../models/chat_thread.dart';

class ChatRepository extends ChatRepositoryBase {
  ChatRepository({
    required super.firestore,
    required super.authRepository,
    ChatFirestoreMapper? mapper,
    ChatContactPolicy? contactPolicy,
  }) : _mapper = mapper ?? const ChatFirestoreMapper(),
       _contactPolicy = contactPolicy ?? const ChatContactPolicy();

  final ChatFirestoreMapper _mapper;
  final ChatContactPolicy _contactPolicy;

  Stream<List<ChatThread>> watchThreads() async* {
    yield* authRepository.idTokenChanges.asyncExpand((user) {
      if (user == null) {
        return Stream.value(const <ChatThread>[]);
      }
      final query = threadsForUser(user.id);
      return query.snapshots().map((snapshot) {
        final threads = snapshot.docs
            .map((doc) => _mapper.threadFromDoc(doc, currentUserId: user.id))
            .toList();
        threads.sort(
          (a, b) => b.lastMessage.sentAt.compareTo(a.lastMessage.sentAt),
        );
        return threads;
      });
    });
  }

  /// Watches a single aggregated counter for unread chats.
  ///
  /// Expected Firestore doc:
  /// `musicians/{uid}/counters/chat` with an integer field `unreadTotal`.
  Stream<int> watchUnreadTotal() async* {
    yield* authRepository.idTokenChanges.asyncExpand((user) async* {
      if (user == null) {
        yield 0;
        return;
      }

      final ref = chatCounters(user.id);

      try {
        await for (final snapshot in ref.snapshots()) {
          final data = snapshot.data();
          final raw = (data?['unreadTotal'] ?? 0);
          if (raw is num) {
            yield raw.toInt();
            continue;
          }
          yield int.tryParse(raw.toString()) ?? 0;
        }
      } on FirebaseException catch (error) {
        if (error.code == 'permission-denied') {
          yield 0;
          return;
        }
        rethrow;
      }
    });
  }

  Future<List<ChatThread>> fetchThreads() async {
    final currentUser = authRepository.currentUser;
    if (currentUser == null) {
      log('fetchThreads: No current user. Returning empty list.');
      return const [];
    }
    try {
      log('fetchThreads: Fetching for user ${currentUser.id}');
      final query = threadsForUser(currentUser.id);

      final snapshot = await query.get();

      final threadList = snapshot.docs
          .map(
            (doc) => _mapper.threadFromDoc(doc, currentUserId: currentUser.id),
          )
          .toList();
      log(
        'fetchThreads: ${threadList.length} threads mapped. Sorting by last message timestamp.',
      );
      threadList.sort(
        (a, b) => b.lastMessage.sentAt.compareTo(a.lastMessage.sentAt),
      );
      log('fetchThreads: Found ${threadList.length} threads.');
      return threadList;
    } on FirebaseException catch (error) {
      log('fetchThreads: FirebaseException - ${error.code}: ${error.message}');
      if (error.code == 'permission-denied') {
        throw Exception('No tienes permisos para ver tus conversaciones.');
      }
      rethrow;
    }
  }

  Future<ChatThread?> fetchThread(String threadId) async {
    final currentUser = authRepository.currentUser;
    if (currentUser == null) {
      log('fetchThread: No current user. Returning null.');
      return null;
    }
    final normalizedId = threadId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }
    try {
      log('fetchThread: Fetching thread $normalizedId');
      final doc = await threadDoc(normalizedId).get();
      if (!doc.exists) {
        log('fetchThread: Thread $normalizedId not found.');
        return null;
      }
      return _mapper.threadFromDoc(doc, currentUserId: currentUser.id);
    } on FirebaseException catch (error) {
      log('fetchThread: FirebaseException - ${error.code}: ${error.message}');
      if (error.code == 'permission-denied') {
        throw Exception('No tienes permisos para abrir este chat.');
      }
      rethrow;
    }
  }

  Future<void> markThreadRead(String threadId) async {
    final user = authRepository.currentUser;
    if (user == null || threadId.trim().isEmpty) return;
    final docRef = threadDoc(threadId);
    try {
      log('markThreadRead: Setting unreadCounts.${user.id}=0 for $threadId');
      await docRef.update({'unreadCounts.${user.id}': 0});
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        // Reading messages should still work even if unread tracking is blocked by rules.
        log(
          'markThreadRead: permission-denied for $threadId (${error.message})',
        );
        return;
      }
      if (error.code == 'not-found') {
        // Avoid creating incomplete thread documents; thread creation requires
        // participants + createdAt and is handled elsewhere.
        log('markThreadRead: thread not found for $threadId');
        return;
      }
      rethrow;
    }
  }

  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    final currentUser = authRepository.currentUser;
    try {
      log('fetchMessages: Fetching messages for thread $threadId');
      final snapshot = await messages(
        threadId,
      ).orderBy('sentAt', descending: false).get();
      final messageList = snapshot.docs
          .map(
            (doc) => _mapper.messageFromQueryDoc(
              doc,
              currentUserId: currentUser?.id,
            ),
          )
          .toList();
      log(
        'fetchMessages: Found ${messageList.length} messages for thread $threadId',
      );
      return messageList;
    } on FirebaseException catch (error) {
      log('fetchMessages: FirebaseException - ${error.code}: ${error.message}');
      if (error.code == 'permission-denied') {
        throw Exception('No tienes permisos para leer los mensajes.');
      }
      rethrow;
    }
  }

  Future<ChatMessage> sendMessage(String threadId, String body) async {
    final user = authRepository.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para enviar mensajes.');
    }
    await _ensureCanSendInThread(threadId: threadId, senderUid: user.id);
    try {
      log('sendMessage: User ${user.id} sending "$body" to thread $threadId');
      final messagesCollection = messages(threadId);
      final now = DateTime.now();
      final docRef = messagesCollection.doc();
      final payload = {
        'sender': user.displayName,
        'senderId': user.id,
        'body': body,
        'sentAt': Timestamp.fromDate(now),
      };
      await docRef.set(payload);

      final lastMessage = {'id': docRef.id, ...payload};
      try {
        await threadDoc(threadId).update({
          'lastMessage': lastMessage,
          'lastMessageAt': Timestamp.fromDate(now),
        });
      } on FirebaseException catch (error) {
        if (error.code == 'permission-denied' || error.code == 'not-found') {
          log(
            'sendMessage: Skipping thread update ($threadId) - ${error.code}: ${error.message}',
          );
        } else {
          rethrow;
        }
      }
      return ChatMessage(
        id: docRef.id,
        sender: user.id,
        body: body,
        sentAt: now,
        isMine: true,
      );
    } on FirebaseException catch (error) {
      log('sendMessage: FirebaseException - ${error.code}: ${error.message}');
      if (error.code == 'permission-denied') {
        throw Exception(
          'No tienes permisos para enviar mensajes en este chat.',
        );
      }
      rethrow;
    }
  }

  Future<ChatThread> ensureThreadWithParticipant({
    required String participantId,
    required String participantName,
  }) async {
    final user = authRepository.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para iniciar una conversación.');
    }
    if (participantId.isEmpty) {
      throw Exception('El destinatario no es válido.');
    }
    if (participantId == user.id) {
      throw Exception('No puedes iniciar un chat contigo mismo.');
    }
    await _ensureCanStartConversation(
      initiatorUid: user.id,
      participantUid: participantId,
    );

    final participantIds = [user.id, participantId]..sort();
    final threadId = participantIds.join('_');
    log(
      'ensureThreadWithParticipant: Ensuring thread $threadId for users ${user.id} and $participantId',
    );

    try {
      final docRef = threadDoc(threadId);
      final existingDoc = await docRef.get();

      final myName = user.displayName.trim().isEmpty
          ? 'Tú'
          : user.displayName.trim();

      final otherName = participantName.trim().isEmpty
          ? 'Músico'
          : participantName.trim();
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);
      final participantLabels = {user.id: myName, participantId: otherName};
      final payload = {
        'participants': participantIds,
        'participantLabels': participantLabels,
        'lastMessageAt': timestamp,
        'createdAt': timestamp,
        'unreadCounts': {user.id: 0, participantId: 0},
      };

      if (existingDoc.exists) {
        final data = existingDoc.data();
        final participants = data?['participants'];
        final isParticipantList =
            participants is List && participants.isNotEmpty;
        final includesCurrentUser =
            isParticipantList && participants.contains(user.id);
        if (includesCurrentUser) {
          log('ensureThreadWithParticipant: Thread $threadId already exists.');
          return _mapper.threadFromDoc(existingDoc, currentUserId: user.id);
        }

        log(
          'ensureThreadWithParticipant: Thread $threadId exists but is incomplete. Repairing.',
        );
        await docRef.set(payload, SetOptions(merge: true));
        final repaired = await docRef.get();
        return _mapper.threadFromDoc(repaired, currentUserId: user.id);
      }

      log(
        'ensureThreadWithParticipant: Creating new thread $threadId. My name: "$myName", other name: "$otherName"',
      );
      await docRef.set(payload);
      return _mapper.threadFromMap(threadId, payload, currentUserId: user.id);
    } on FirebaseException catch (error) {
      log(
        'ensureThreadWithParticipant: FirebaseException - ${error.code}: ${error.message}',
      );
      if (error.code == 'permission-denied') {
        throw Exception('No tienes permisos para iniciar este chat.');
      }
      rethrow;
    }
  }

  Future<void> _ensureCanSendInThread({
    required String threadId,
    required String senderUid,
  }) async {
    final snapshot = await threadDoc(threadId).get();
    if (!snapshot.exists) {
      throw Exception('No se encontró el chat.');
    }

    final participants = _stringList(snapshot.data()?['participants']);
    if (!participants.contains(senderUid)) {
      throw Exception('No tienes permisos para enviar mensajes en este chat.');
    }

    if (participants.length != 2) {
      return;
    }

    final otherUid = participants.firstWhere(
      (participant) => participant != senderUid,
      orElse: () => '',
    );
    if (otherUid.isEmpty) {
      return;
    }

    await _ensureCanStartConversation(
      initiatorUid: senderUid,
      participantUid: otherUid,
    );
  }

  Future<void> _ensureCanStartConversation({
    required String initiatorUid,
    required String participantUid,
  }) async {
    final initiatorKind = await _resolveActorKind(initiatorUid);
    final participantKind = await _resolveActorKind(participantUid);

    var hasAcceptedRecruitment = false;
    if (_isEventManagerMusicianPair(initiatorKind, participantKind)) {
      final managerUid = initiatorKind == ChatActorKind.eventManager
          ? initiatorUid
          : participantUid;
      final musicianUid = initiatorKind == ChatActorKind.musician
          ? initiatorUid
          : participantUid;
      hasAcceptedRecruitment = await _hasAcceptedRecruitment(
        managerUid: managerUid,
        musicianUid: musicianUid,
      );
    }

    final denyReason = _contactPolicy.denyReason(
      initiator: initiatorKind,
      participant: participantKind,
      hasAcceptedRecruitment: hasAcceptedRecruitment,
    );

    if (denyReason != null) {
      throw Exception(denyReason);
    }
  }

  bool _isEventManagerMusicianPair(ChatActorKind left, ChatActorKind right) {
    return (left == ChatActorKind.eventManager &&
            right == ChatActorKind.musician) ||
        (left == ChatActorKind.musician && right == ChatActorKind.eventManager);
  }

  Future<ChatActorKind> _resolveActorKind(String uid) async {
    final normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      return ChatActorKind.unknown;
    }

    final managerProfile = await _eventManagerProfile(normalizedUid);
    if (managerProfile != null) {
      final specialties = _stringList(
        managerProfile['specialties'],
      ).map((item) => item.toLowerCase()).toSet();
      final isVenueOnly =
          specialties.length == 1 && specialties.contains('venues');
      return isVenueOnly ? ChatActorKind.venue : ChatActorKind.eventManager;
    }

    final studioSnapshot = await firestore
        .collection('studios')
        .where('ownerId', isEqualTo: normalizedUid)
        .limit(1)
        .get();
    if (studioSnapshot.docs.isNotEmpty) {
      return ChatActorKind.studio;
    }

    final musicianSnapshot = await firestore
        .collection('musicians')
        .doc(normalizedUid)
        .get();
    if (musicianSnapshot.exists) {
      return ChatActorKind.musician;
    }

    return ChatActorKind.unknown;
  }

  Future<Map<String, dynamic>?> _eventManagerProfile(String uid) async {
    final byId = await firestore.collection('event_managers').doc(uid).get();
    if (byId.exists) {
      return byId.data();
    }

    final byOwner = await firestore
        .collection('event_managers')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();

    if (byOwner.docs.isEmpty) {
      return null;
    }

    return byOwner.docs.first.data();
  }

  Future<bool> _hasAcceptedRecruitment({
    required String managerUid,
    required String musicianUid,
  }) async {
    final permissionId = '${managerUid}_$musicianUid';
    final permissionDoc = await firestore
        .collection('chat_permissions')
        .doc(permissionId)
        .get();
    return permissionDoc.exists;
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((item) => item.toString()).toList();
    }
    return const <String>[];
  }
}
