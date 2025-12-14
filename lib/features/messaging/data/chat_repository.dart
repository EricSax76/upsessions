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
      return const [];
    }
    try {
      final query = _firestore
          .collection('chat_threads')
          .where('participantIds', arrayContains: currentUser.id);

      final snapshot = await query
          .orderBy('lastMessageAt', descending: true)
          .get();

      final threads = snapshot.docs
          .map((doc) => _mapThread(doc, currentUser.id))
          .toList();
      threads.sort(
        (a, b) => b.lastMessage.sentAt.compareTo(a.lastMessage.sentAt),
      );
      return threads;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw Exception('No tienes permisos para ver tus conversaciones.');
      }
      rethrow;
    }
  }

  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    final currentUser = _authRepository.currentUser;
    try {
      final snapshot = await _firestore
          .collection('chat_threads')
          .doc(threadId)
          .collection('messages')
          .orderBy('sentAt', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => _mapMessage(doc, currentUser?.id))
          .toList();
    } on FirebaseException catch (error) {
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

    try {
      final docRef = _firestore.collection('chat_threads').doc(threadId);
      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        return _mapThread(existingDoc, user.id);
      }

      final otherName = participantName.trim().isEmpty
          ? 'Músico'
          : participantName.trim();
      final myName = user.displayName.trim().isEmpty
          ? 'Tú'
          : user.displayName.trim();

      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);
      final participantLabels = {user.id: myName, participantId: otherName};
      final payload = {
        'participantIds': participantIds,
        'participantLabels': participantLabels,
        'lastMessageAt': timestamp,
        'createdAt': timestamp,
        'unreadCounts': {user.id: 0, participantId: 0},
      };

      await docRef.set(payload);
      await _createMessagesPlaceholder(
        docRef: docRef,
        userId: user.id,
        userDisplayName: myName,
      );
      return _mapThreadFromMap(threadId, payload, user.id);
    } on FirebaseException catch (error) {
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
    return ChatThread(
      id: docId,
      participants: _stringList(data['participantIds']),
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
    return ChatMessage(
      id: id ?? (data['id'] ?? '') as String,
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

  Future<void> _createMessagesPlaceholder({
    required DocumentReference<Map<String, dynamic>> docRef,
    required String userId,
    required String userDisplayName,
  }) async {
    try {
      final messagesCollection = docRef.collection('messages');
      await messagesCollection.doc('__placeholder__').set({
        'sender': userDisplayName,
        'senderId': userId,
        'body': '¡Chat iniciado!',
        'sentAt': Timestamp.now(),
      });
    } catch (_) {
      // Ignoramos errores: el placeholder solo es para visibilidad temprana.
    }
  }
}
