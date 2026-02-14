import 'package:flutter/material.dart';

import '../../../musicians/models/musician_entity.dart';
import '../../../../core/services/dialog_service.dart';
import '../../controllers/group_rehearsals_controller.dart';
import '../../controllers/invite_musician_controller.dart';
import '../widgets/invite_musician_dialog_widgets.dart';

class InviteMusicianDialog extends StatefulWidget {
  const InviteMusicianDialog({
    super.key,
    required this.groupId,
    required this.controller,
  });

  final String groupId;
  final GroupRehearsalsController controller;

  @override
  State<InviteMusicianDialog> createState() => _InviteMusicianDialogState();
}

class _InviteMusicianDialogState extends State<InviteMusicianDialog> {
  late final InviteMusicianDialogController _dialogController;

  @override
  void initState() {
    super.initState();
    _dialogController = InviteMusicianDialogController(
      controller: widget.controller,
      groupId: widget.groupId,
    );
  }

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogController,
      builder: (context, _) => InviteMusicianDialogView(
        controller: _dialogController,
        state: _dialogController.state,
        onInviteTap: _handleInviteTap,
      ),
    );
  }

  Future<void> _handleInviteTap(MusicianEntity target) async {
    try {
      final link = await _dialogController.createInvite(target);
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => InviteCreatedDialog(link: link, target: target),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      DialogService.showError(
        context,
        'No se pudo crear la invitación: $error',
      );
    }
  }
}
