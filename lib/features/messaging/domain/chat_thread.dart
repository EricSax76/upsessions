import 'package:flutter/foundation.dart';

import 'chat_message.dart';

@immutable
class ChatThread {
  const ChatThread({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.unreadCount,
  });

  final String id;
  final List<String> participants;
  final ChatMessage lastMessage;
  final int unreadCount;
}
