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
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? AuthRepository(),
        _cloudFunctionsService = cloudFunctionsService ?? CloudFunctionsService();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final CloudFunctionsService _cloudFunctionsService;

  Future<List<ChatThread>> fetchThreads() async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      return const [];
    }
    final tokens = _identityTokens(primary: currentUser.id, secondary: currentUser.email);
    final docs = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final token in tokens) {
      final baseQuery =
          _firestore.collection('chat_threads').where('participants', arrayContains: token);
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await baseQuery.orderBy('lastMessageAt', descending: true).get();
      } on FirebaseException catch (error) {
        if (error.code == 'failed-precondition') {
          snapshot = await baseQuery.get();
        } else {
          rethrow;
        }
      }
      for (final doc in snapshot.docs) {
        docs[doc.id] = doc;
      }
    }
    final threads = docs.values
        .map((doc) => _mapThread(doc, currentUser.id, currentUser.email))
        .toList();
    threads.sort(
      (a, b) => b.lastMessage.sentAt.compareTo(a.lastMessage.sentAt),
    );
    return threads;
  }

  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    final currentUser = _authRepository.currentUser;
    final snapshot = await _firestore
        .collection('chat_threads')
        .doc(threadId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => _mapMessage(doc, currentUser?.id, currentUser?.email))
        .toList();
  }

  Future<ChatMessage> sendMessage(String threadId, String body) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para enviar mensajes.');
    }
    final messagesCollection = _firestore.collection('chat_threads').doc(threadId).collection('messages');
    final now = DateTime.now();
    final docRef = messagesCollection.doc();
    final payload = {
      'sender': user.id,
      'senderEmail': user.email,
      'senderId': user.id,
      'body': body,
      'sentAt': Timestamp.fromDate(now),
    };
    await docRef.set(payload);
    final lastMessage = {
      'id': docRef.id,
      ...payload,
    };
    await _firestore.collection('chat_threads').doc(threadId).update({
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(now),
    });
    await _cloudFunctionsService.notifyChatMessage(threadId: threadId, sender: user.id, body: body);
    return ChatMessage(
      id: docRef.id,
      sender: user.id,
      body: body,
      sentAt: now,
      isMine: true,
    );
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
    final otherName = participantName.trim().isEmpty ? 'Músico' : participantName.trim();
    final myName = user.displayName.trim().isEmpty ? 'Tú' : user.displayName.trim();
    final myTokens = _identityTokens(primary: user.id, secondary: user.email);
    final otherTokens = _identityTokens(primary: participantId);
    final existingSnapshot = await _firestore
        .collection('chat_threads')
        .where('participants', arrayContainsAny: myTokens)
        .get();
    QueryDocumentSnapshot<Map<String, dynamic>>? existingDoc;

    for (final doc in existingSnapshot.docs) {
      final participants = _stringList(doc.data()['participants']);
      if (participants.any((value) => otherTokens.contains(value))) {
        existingDoc = doc;
        break;
      }
    }

    if (existingDoc != null) {
      final data = existingDoc.data();
      final rawLabels = data['participantLabels'];
      final Map<String, dynamic> currentLabels = rawLabels is Map<String, dynamic>
          ? Map<String, dynamic>.from(rawLabels)
          : <String, dynamic>{};
      bool needsUpdate = false;
      if ((currentLabels[user.id] as String?)?.isEmpty ?? true) {
        currentLabels[user.id] = myName;
        needsUpdate = true;
      }
      if ((currentLabels[participantId] as String?)?.isEmpty ?? true) {
        currentLabels[participantId] = otherName;
        needsUpdate = true;
      }
      if (needsUpdate) {
        await existingDoc.reference.set({'participantLabels': currentLabels}, SetOptions(merge: true));
        data['participantLabels'] = currentLabels;
      }
      return _mapThreadFromMap(existingDoc.id, data, user.id, user.email);
    }

    final sortedIds = [user.id, participantId]..sort();
    final threadId = sortedIds.join('_');
    final docRef = _firestore.collection('chat_threads').doc(threadId);

    final now = DateTime.now();
    final timestamp = Timestamp.fromDate(now);
    final participantLabels = {
      user.id: myName,
      participantId: otherName,
    };
    final payload = {
      'participants': _buildParticipantsPayload(myTokens: myTokens, otherTokens: otherTokens),
      'participantLabels': participantLabels,
      'lastMessage': {
        'id': '',
        'sender': user.id,
        'senderId': user.id,
        'senderEmail': user.email,
        'body': '',
        'sentAt': timestamp,
      },
      'lastMessageAt': timestamp,
      'createdAt': timestamp,
      'unreadCounts': {
        user.id: 0,
        participantId: 0,
      },
    };
    await docRef.set(payload);
    return _mapThreadFromMap(threadId, payload, user.id, user.email);
  }

  ChatThread _mapThread(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String currentUserId,
    String? currentEmail,
  ) {
    return _mapThreadFromMap(doc.id, doc.data(), currentUserId, currentEmail);
  }

  ChatThread _mapThreadFromMap(
    String docId,
    Map<String, dynamic> data,
    String currentUserId,
    String? currentEmail,
  ) {
    final lastMessageMap = (data['lastMessage'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    return ChatThread(
      id: docId,
      participants: _stringList(data['participants']),
      participantLabels: _stringMap(data['participantLabels']),
      lastMessage: _mapMessageFromMap(lastMessageMap, currentUserId, currentEmail),
      unreadCount: _unreadCount(data['unreadCounts'], currentUserId, currentEmail),
    );
  }

  ChatMessage _mapMessage(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String? currentUserId,
    String? currentEmail,
  ) {
    final data = doc.data();
    return _mapMessageFromMap(data, currentUserId, currentEmail, id: doc.id);
  }

  ChatMessage _mapMessageFromMap(
    Map<String, dynamic> data,
    String? currentUserId,
    String? currentEmail, {
    String? id,
  }) {
    final senderId = (data['senderId'] ?? data['sender'] ?? '') as String;
    final senderEmail = (data['senderEmail'] ?? data['sender'] ?? '') as String;
    final resolvedSender = senderId.isNotEmpty ? senderId : senderEmail;
    final matchesId = currentUserId != null && resolvedSender == currentUserId;
    final matchesEmail = currentEmail != null && senderEmail == currentEmail;
    return ChatMessage(
      id: id ?? (data['id'] ?? '') as String,
      sender: resolvedSender,
      body: (data['body'] ?? '') as String,
      sentAt: _parseTimestamp(data['sentAt']),
      isMine: matchesId || matchesEmail,
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

  static int _unreadCount(dynamic raw, String currentUserId, String? currentEmail) {
    if (raw is Map<String, dynamic>) {
      final value = raw[currentUserId] ?? (currentEmail != null ? raw[currentEmail] : null);
      if (value is num) {
        return value.toInt();
      }
    }
    return 0;
  }

  static List<String> _identityTokens({required String primary, String? secondary}) {
    final tokens = <String>{primary.trim()};
    if (secondary != null && secondary.trim().isNotEmpty) {
      tokens.add(secondary.trim());
    }
    tokens.removeWhere((element) => element.isEmpty);
    return tokens.toList();
  }

  static List<String> _buildParticipantsPayload({
    required List<String> myTokens,
    required List<String> otherTokens,
  }) {
    final combined = {...myTokens, ...otherTokens}.toList();
    combined.sort();
    return combined;
  }
}
