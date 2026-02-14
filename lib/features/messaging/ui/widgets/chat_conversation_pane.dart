import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import 'chat_input_field.dart';
import 'message_bubble.dart';

class ChatConversationPane extends StatelessWidget {
  const ChatConversationPane({
    super.key,
    required this.messages,
    required this.hasSelectedThread,
    required this.onSend,
  });

  final List<ChatMessage> messages;
  final bool hasSelectedThread;
  final Future<void> Function(String text) onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Expanded(
            child: hasSelectedThread
                ? ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        MessageBubble(message: messages[index]),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 64,
                          color: scheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selecciona una conversación',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          if (hasSelectedThread)
            ChatInputField(onSend: onSend)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
