import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../../../features/notifications/repositories/invite_notifications_repository.dart';
import '../../../groups/repositories/groups_repository.dart';

class InviteAcceptPage extends StatefulWidget {
  const InviteAcceptPage({
    super.key,
    required this.groupId,
    required this.inviteId,
    required this.groupsRepository,
    required this.inviteNotificationsRepository,
    required this.authRepository,
  });

  final String groupId;
  final String inviteId;
  final GroupsRepository groupsRepository;
  final InviteNotificationsRepository inviteNotificationsRepository;
  final AuthRepository authRepository;

  @override
  State<InviteAcceptPage> createState() => _InviteAcceptPageState();
}

class _InviteAcceptPageState extends State<InviteAcceptPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isAuthenticated =
        authState.status == AuthStatus.authenticated &&
        widget.authRepository.currentUser != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Invitación')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Has recibido una invitación a un grupo de ensayos.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (widget.groupId.isEmpty || widget.inviteId.isEmpty)
                  const Text(
                    'Link inválido (faltan parámetros).',
                    textAlign: TextAlign.center,
                  )
                else if (!isAuthenticated)
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Iniciar sesión'),
                  )
                else
                  FilledButton.icon(
                    onPressed: _loading ? null : () => _accept(context),
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Aceptar invitación'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    setState(() => _loading = true);
    try {
      await widget.groupsRepository.acceptInvite(
        groupId: widget.groupId,
        inviteId: widget.inviteId,
      );
      await widget.inviteNotificationsRepository.updateStatus(
        widget.inviteId,
        'accepted',
      );
      if (!context.mounted) return;
      context.go(AppRoutes.groupPage(widget.groupId));
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(context, 'No se pudo aceptar: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
