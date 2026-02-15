import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/chat_thread_detail_cubit.dart';
import '../../models/chat_thread.dart';
import '../../repositories/chat_repository.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/message_bubble.dart';

class ChatThreadDetailPage extends StatelessWidget {
  const ChatThreadDetailPage({
    super.key,
    required this.thread,
    required this.threadTitle,
    required this.chatRepository,
  });

  final ChatRepository chatRepository;

  final ChatThread thread;
  final String threadTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ChatThreadDetailCubit(chatRepository: chatRepository)
            ..loadMessages(thread.id, unreadCount: thread.unreadCount),
      child: _ChatThreadDetailView(
        threadId: thread.id,
        threadTitle: threadTitle,
      ),
    );
  }
}

class _ChatThreadDetailView extends StatelessWidget {
  const _ChatThreadDetailView({
    required this.threadId,
    required this.threadTitle,
  });

  final String threadId;
  final String threadTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(threadTitle)),
      body: BlocConsumer<ChatThreadDetailCubit, ChatThreadDetailState>(
        listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChatThreadDetailCubit>();

          final Widget messageArea;
          if (state.isLoading) {
            messageArea = const Center(child: CircularProgressIndicator());
          } else if (state.messages.isEmpty) {
            messageArea = const Center(child: Text('Aún no hay mensajes.'));
          } else {
            messageArea = ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) =>
                  MessageBubble(message: state.messages[index]),
            );
          }

          return Column(
            children: [
              Expanded(child: messageArea),
              ChatInputField(
                onSend: (text) => cubit.sendMessage(threadId, text),
              ),
            ],
          );
        },
      ),
    );
  }
}
