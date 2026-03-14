import 'package:flutter/foundation.dart';

import 'chat_message.dart';

@immutable
class ChatThread {
  const ChatThread({
    required this.id,
    required this.participants,
    required this.participantLabels,
    required this.lastMessage,
    required this.unreadCount,
  });

  final String id;
  final List<String> participants;
  final Map<String, String> participantLabels;
  final ChatMessage lastMessage;
  final int unreadCount;

  /// Returns the display name for the participant that is not the current user.
  String titleFor(String currentUserId) {
    for (final participantId in participants) {
      if (participantId == currentUserId) {
        continue;
      }
      final label = participantLabels[participantId];
      if (label != null && label.isNotEmpty) {
        return label;
      }
    }
    return participantLabels[currentUserId] ?? 'Conversación';
  }
}
