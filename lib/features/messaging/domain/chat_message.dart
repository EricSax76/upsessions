import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.sentAt,
    this.isMine = false,
  });

  final String id;
  final String sender;
  final String body;
  final DateTime sentAt;
  final bool isMine;
}
