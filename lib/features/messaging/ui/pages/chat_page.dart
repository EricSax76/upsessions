import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';

import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/repositories/profile_repository.dart';

import '../../logic/chat_page_cubit.dart';
import '../../models/chat_thread.dart';
import '../../repositories/chat_repository.dart';
import '../widgets/chat_conversation_pane.dart';
import '../widgets/chat_threads_list_view.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.chatRepository,
    required this.authRepository,
    required this.profileRepository,
    this.showAppBar = true,
    this.initialThreadId,
  });

  final ChatRepository chatRepository;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  final bool showAppBar;
  final String? initialThreadId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatPageCubit _cubit;
  bool _didAutoOpenInitialThread = false;

  @override
  void initState() {
    super.initState();
    _cubit = ChatPageCubit(
      chatRepository: widget.chatRepository,
      authRepository: widget.authRepository,
      profileRepository: widget.profileRepository,
    );
    _cubit.loadThreads(preferThreadId: widget.initialThreadId).then((_) {
      _tryAutoOpenInitialThread();
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _tryAutoOpenInitialThread() {
    if (_didAutoOpenInitialThread || widget.initialThreadId == null) return;
    final thread = _cubit.state.selectedThread;
    if (thread == null) return;
    _didAutoOpenInitialThread = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isCompact = MediaQuery.sizeOf(context).width < 720;
      if (isCompact) _openThreadDetail(thread);
    });
  }

  Future<void> _openThreadDetail(ChatThread thread) async {
    await context.push(
      AppRoutes.messagesThreadDetailPath(thread.id),
      extra: thread,
    );
    if (!mounted) return;
    await _cubit.loadThreads(preferThreadId: thread.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ChatPageCubit, ChatPageState>(
        listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final currentUserId = _cubit.currentUserId;

          final body = LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 720;
              if (isCompact) {
                return ChatThreadsListView(
                  threads: state.threads,
                  currentUserId: currentUserId,
                  selectedThreadId: state.selectedThread?.id,
                  avatarUrlsByUserId: state.avatarUrlsByUserId,
                  lastMessageByThreadId: state.lastMessageByThreadId,
                  isCompact: true,
                  onSelectThread: _cubit.selectThread,
                  onOpenThreadDetail: _openThreadDetail,
                );
              }
              return Row(
                children: [
                  SizedBox(
                    width: 320,
                    child: ChatThreadsListView(
                      threads: state.threads,
                      currentUserId: currentUserId,
                      selectedThreadId: state.selectedThread?.id,
                      avatarUrlsByUserId: state.avatarUrlsByUserId,
                      lastMessageByThreadId: state.lastMessageByThreadId,
                      isCompact: false,
                      onSelectThread: _cubit.selectThread,
                      onOpenThreadDetail: _openThreadDetail,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChatConversationPane(
                      messages: state.messages,
                      hasSelectedThread: state.selectedThread != null,
                      onSend: _cubit.sendMessage,
                    ),
                  ),
                ],
              );
            },
          );

          if (!widget.showAppBar) {
            return SafeArea(child: body);
          }

          // If we still want to support standalone usage with AppBar (e.g. on mobile if needed outside shell, though likely not for CoreShell compliance)
          // For now, let's assume it should fit in the shell.
          // However, the existing logic handled both. Since we are moving to Core Shell,
          // the shell provides the structure. `showAppBar` was false in MessagesPage.
          // If showAppBar is true, it used a Scaffold.
          // We can remove the Scaffold entirely and rely on the shell.
          return SafeArea(child: body);
        },
      ),
    );
  }
}
