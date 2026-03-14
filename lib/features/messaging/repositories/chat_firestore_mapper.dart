import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';
import '../models/chat_thread.dart';

class ChatFirestoreMapper {
  const ChatFirestoreMapper();

  ChatThread threadFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String currentUserId,
  }) {
    return threadFromMap(
      doc.id,
      doc.data() ?? const <String, dynamic>{},
      currentUserId: currentUserId,
    );
  }

  ChatThread threadFromMap(
    String threadId,
    Map<String, dynamic> data, {
    required String currentUserId,
  }) {
    final lastMessageMap = _stringDynamicMap(data['lastMessage']);
    final unreadCount = _unreadCount(data['unreadCounts'], currentUserId);

    final fallbackTimestamp = _parseTimestamp(
      data['lastMessageAt'] ?? data['createdAt'],
    );

    final mappedLastMessage = messageFromMap(
      lastMessageMap,
      currentUserId: currentUserId,
    );

    final lastMessage = mappedLastMessage.id.isEmpty
        ? ChatMessage(
            id: '',
            sender: '',
            body: 'Aún no hay mensajes.',
            sentAt: fallbackTimestamp,
            isMine: false,
          )
        : mappedLastMessage;

    return ChatThread(
      id: threadId,
      participants: _stringList(data['participants']),
      participantLabels: _stringMap(data['participantLabels']),
      lastMessage: lastMessage,
      unreadCount: unreadCount,
    );
  }

  ChatMessage messageFromQueryDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    String? currentUserId,
  }) {
    return messageFromMap(doc.data(), currentUserId: currentUserId, id: doc.id);
  }

  ChatMessage messageFromMap(
    Map<String, dynamic> data, {
    String? currentUserId,
    String? id,
  }) {
    final senderId = (data['senderId'] ?? '').toString();
    final messageId = _messageIdFrom(data, id);
    if (messageId.isEmpty) {
      return ChatMessage.placeholder();
    }
    return ChatMessage(
      id: messageId,
      sender: senderId,
      body: (data['body'] ?? '').toString(),
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
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    return DateTime.fromMillisecondsSinceEpoch(0);
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

  static Map<String, dynamic> _stringDynamicMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  static int _unreadCount(dynamic raw, String currentUserId) {
    if (raw is Map) {
      final value = raw[currentUserId];
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  static String _messageIdFrom(Map<String, dynamic> data, String? fallbackId) {
    final messageId = fallbackId?.toString() ?? '';
    if (messageId.isNotEmpty) {
      return messageId;
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
