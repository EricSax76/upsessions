import '../domain/chat_message.dart';

class MessageDto {
  const MessageDto({
    required this.id,
    required this.sender,
    required this.body,
    required this.sentAt,
  });

  final String id;
  final String sender;
  final String body;
  final DateTime sentAt;

  ChatMessage toEntity({required bool isMine}) {
    return ChatMessage(
      id: id,
      sender: sender,
      body: body,
      sentAt: sentAt,
      isMine: isMine,
    );
  }
}
