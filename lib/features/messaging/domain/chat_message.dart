import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.sentAt,
    this.isMine = true,
  });

  final String id;
  final String sender;
  final String body;
  final DateTime sentAt;
  final bool isMine;

  factory ChatMessage.placeholder() => ChatMessage(
    id: '',
    sender: '',
    body: 'Aún no hay mensajes.',
    sentAt: DateTime.now(),
    isMine: false,
  );
}
