import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/cloud_functions_service.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';

class ChatRepository {
  ChatRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
    CloudFunctionsService? cloudFunctionsService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _authRepository = authRepository ?? AuthRepository(),
       _cloudFunctionsService =
           cloudFunctionsService ?? CloudFunctionsService();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final CloudFunctionsService _cloudFunctionsService;

  Future<List<ChatThread>> fetchThreads() async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      print(
        '[ChatRepository] fetchThreads: No current user. Returning empty list.',
      );
      return const [];
    }
    try {
      print(
        '[ChatRepository] fetchThreads: Fetching for user ${currentUser.id}',
      );
      final query = _firestore
          .collection('chat_threads')
          .where('participants', arrayContains: currentUser.id);

      final snapshot =
          await query //
              .get();

      final threads = snapshot.docs
          .map((doc) => _mapThread(doc, currentUser.id))
          .toList();
      print(
        '[ChatRepository] fetchThreads: ${threads.length} threads mapped. Sorting by last message timestamp.',
      );
      threads.sort(
        (a, b) => b.lastMessage.sentAt.compareTo(a.lastMessage.sentAt),
      );
      print('[ChatRepository] fetchThreads: Found ${threads.length} threads.');
      return threads;
    } on FirebaseException catch (error) {
      print(
        '[ChatRepository] fetchThreads: FirebaseException - ${error.code}: ${error.message}',
      );
      if (error.code == 'permission-denied') {
        throw Exception('No tienes permisos para ver tus conversaciones.');
      }
      rethrow;
    }
  }

  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    final currentUser = _authRepository.currentUser;
    try {
      print(
        '[ChatRepository] fetchMessages: Fetching messages for thread $threadId',
      );
      final snapshot = await _firestore
          .collection('chat_threads')
          .doc(threadId)
          .collection('messages')
          .orderBy('sentAt', descending: false)
          .get();
      final messages = snapshot.docs
          .map((doc) => _mapMessage(doc, currentUser?.id))
          .toList();
      print(
        '[ChatRepository] fetchMessages: Found ${messages.length} messages for thread $threadId',
      );
      return messages;
    } on FirebaseException catch (error) {
      print(
        '[ChatRepository] fetchMessages: FirebaseException - ${error.code}: ${error.message}',
      );
      if (error.code == 'permission-denied') {
        throw Exception('No tienes permisos para leer los mensajes.');
      }
      rethrow;
    }
  }

  Future<ChatMessage> sendMessage(String threadId, String body) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para enviar mensajes.');
    }
    try {
      print(
        '[ChatRepository] sendMessage: User ${user.id} sending "$body" to thread $threadId',
      );
      final messagesCollection = _firestore
          .collection('chat_threads')
          .doc(threadId)
          .collection('messages');
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
      await _firestore.collection('chat_threads').doc(threadId).update({
        'lastMessage': lastMessage,
        'lastMessageAt': Timestamp.fromDate(now),
      });
      await _cloudFunctionsService.notifyChatMessage(
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
      print(
        '[ChatRepository] sendMessage: FirebaseException - ${error.code}: ${error.message}',
      );
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
    final user = _authRepository.currentUser;
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
    print(
      '[ChatRepository] ensureThreadWithParticipant: Ensuring thread $threadId for users ${user.id} and $participantId',
    );

    try {
      final docRef = _firestore.collection('chat_threads').doc(threadId);
      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        print(
          '[ChatRepository] ensureThreadWithParticipant: Thread $threadId already exists.',
        );
        return _mapThread(existingDoc, user.id);
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
      print(
        '[ChatRepository] ensureThreadWithParticipant: Creating new thread $threadId. My name: "$myName", other name: "$otherName"',
      );
      final payload = {
        'participants': participantIds,
        'participantLabels': participantLabels,
        'lastMessageAt': timestamp,
        'createdAt': timestamp,
        'unreadCounts': {user.id: 0, participantId: 0},
      };

      await docRef.set(payload);
      // await _createMessagesPlaceholder(
      //   docRef: docRef,
      //   userId: user.id,
      //   userDisplayName: myName,
      // );
      return _mapThreadFromMap(threadId, payload, user.id);
    } on FirebaseException catch (error) {
      print(
        '[ChatRepository] ensureThreadWithParticipant: FirebaseException - ${error.code}: ${error.message}',
      );
      if (error.code == 'permission-denied') {
        throw Exception('No tienes permisos para iniciar este chat.');
      }
      rethrow;
    }
  }

  ChatThread _mapThread(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String currentUserId,
  ) {
    return _mapThreadFromMap(doc.id, doc.data()!, currentUserId);
  }

  ChatThread _mapThreadFromMap(
    String docId,
    Map<String, dynamic> data,
    String currentUserId,
  ) {
    final lastMessageMap =
        (data['lastMessage'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    print(
      '[ChatRepository] _mapThreadFromMap: Mapping thread ${docId} for user ${currentUserId}.',
    );
    return ChatThread(
      id: docId,
      participants: _stringList(data['participants']),
      participantLabels: _stringMap(data['participantLabels']),
      lastMessage: _mapMessageFromMap(lastMessageMap, currentUserId),
      unreadCount: _unreadCount(data['unreadCounts'], currentUserId),
    );
  }

  ChatMessage _mapMessage(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String? currentUserId,
  ) {
    final data = doc.data();
    return _mapMessageFromMap(data, currentUserId, id: doc.id);
  }

  ChatMessage _mapMessageFromMap(
    Map<String, dynamic> data,
    String? currentUserId, {
    String? id,
  }) {
    final senderId = (data['senderId'] ?? '') as String;
    final messageId = _messageIdFrom(data, id);
    if (messageId.isEmpty) {
      return ChatMessage.placeholder();
    }
    return ChatMessage(
      id: messageId,
      sender: senderId,
      body: (data['body'] ?? '') as String,
      sentAt: _parseTimestamp(data['sentAt']),
      isMine: currentUserId != null && senderId == currentUserId,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    }
    return const {};
  }

  static int _unreadCount(dynamic raw, String currentUserId) {
    if (raw is Map<String, dynamic>) {
      final value = raw[currentUserId];
      if (value is num) {
        return value.toInt();
      }
    }
    return 0;
  }

  static String _messageIdFrom(Map<String, dynamic> data, String? fallbackId) {
    if (fallbackId != null && fallbackId.isNotEmpty) {
      return fallbackId;
    }
    final mapId = data['id'];
    if (mapId is String && mapId.isNotEmpty) {
      return mapId;
    }
    final sentAt = data['sentAt'];
    if (sentAt is Timestamp) {
      return '${sentAt.seconds}_${sentAt.nanoseconds}';
    }
    if (sentAt is DateTime) {
      return sentAt.millisecondsSinceEpoch.toString();
    }
    final senderId = data['senderId'];
    if (senderId is String && senderId.isNotEmpty) {
      return '${senderId}_${DateTime.now().microsecondsSinceEpoch}';
    }
    return '';
  }
}
