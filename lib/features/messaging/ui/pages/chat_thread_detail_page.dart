import 'package:flutter/material.dart';
import 'package:upsessions/core/locator/locator.dart';

import '../../repositories/chat_repository.dart';
import '../../models/chat_message.dart';
import '../../models/chat_thread.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/message_bubble.dart';

class ChatThreadDetailPage extends StatefulWidget {
  const ChatThreadDetailPage({
    super.key,
    required this.thread,
    required this.threadTitle,
  });

  final ChatThread thread;
  final String threadTitle;

  @override
  State<ChatThreadDetailPage> createState() => _ChatThreadDetailPageState();
}

class _ChatThreadDetailPageState extends State<ChatThreadDetailPage> {
  final ChatRepository _repository = locate();
  List<ChatMessage> _messages = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _repository.fetchMessages(widget.thread.id);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      if (widget.thread.unreadCount > 0) {
        _repository.markThreadRead(widget.thread.id);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los mensajes: $error')),
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    try {
      final message = await _repository.sendMessage(widget.thread.id, text);
      if (!mounted) return;
      setState(() => _messages = [..._messages, message]);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar el mensaje: $error')),
      );
    }
  }

  Widget _buildMessages() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_messages.isEmpty) {
      return const Center(child: Text('Aún no hay mensajes.'));
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) => MessageBubble(message: _messages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.threadTitle)),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          ChatInputField(onSend: _sendMessage),
        ],
      ),
    );
  }
}
