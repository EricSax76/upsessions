import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_firestore_mapper.dart';
import 'chat_repository_base.dart';
import '../models/chat_message.dart';
import '../models/chat_thread.dart';

class ChatRepository extends ChatRepositoryBase {
  ChatRepository({
    super.firestore,
    super.authRepository,
    super.cloudFunctionsService,
    ChatFirestoreMapper? mapper,
  }) : _mapper = mapper ?? const ChatFirestoreMapper(),
       super();

  final ChatFirestoreMapper _mapper;

  Stream<List<ChatThread>> watchThreads() async* {
    yield* authRepository.idTokenChanges.asyncExpand((user) {
      if (user == null) {
        return Stream.value(const <ChatThread>[]);
      }
      final query = threads()
          .where('participants', arrayContains: user.id)
          .orderBy('lastMessageAt', descending: true);
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
      final query = threads().where(
        'participants',
        arrayContains: currentUser.id,
      );

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

  Future<void> markThreadRead(String threadId) async {
    final user = authRepository.currentUser;
    if (user == null || threadId.trim().isEmpty) return;
    final docRef = threadDoc(threadId);
    try {
      await docRef.update({'unreadCounts.${user.id}': 0});
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        // Reading messages should still work even if unread tracking is blocked by rules.
        return;
      }
      if (error.code == 'not-found') {
        await docRef.set({
          'unreadCounts': {user.id: 0},
        }, SetOptions(merge: true));
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
      await threadDoc(threadId).update({
        'lastMessage': lastMessage,
        'lastMessageAt': Timestamp.fromDate(now),
      });
      await cloudFunctionsService.notifyChatMessage(
        threadId: threadId,
        sender: user.id,
        body: body,
      );
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

    final participantIds = [user.id, participantId]..sort();
    final threadId = participantIds.join('_');
    log(
      'ensureThreadWithParticipant: Ensuring thread $threadId for users ${user.id} and $participantId',
    );

    try {
      final docRef = threadDoc(threadId);
      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        log('ensureThreadWithParticipant: Thread $threadId already exists.');
        return _mapper.threadFromDoc(existingDoc, currentUserId: user.id);
      }

      final myName = user.displayName.trim().isEmpty
          ? 'Tú'
          : user.displayName.trim();

      final otherName = participantName.trim().isEmpty
          ? 'Músico'
          : participantName.trim();
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);
      final participantLabels = {user.id: myName, participantId: otherName};
      log(
        'ensureThreadWithParticipant: Creating new thread $threadId. My name: "$myName", other name: "$otherName"',
      );
      final payload = {
        'participants': participantIds,
        'participantLabels': participantLabels,
        'lastMessageAt': timestamp,
        'createdAt': timestamp,
        'unreadCounts': {user.id: 0, participantId: 0},
      };

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
}
