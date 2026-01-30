import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upsessions/core/constants/app_link_scheme.dart';

import '../../musicians/models/musician_entity.dart';
import 'group_rehearsals_controller.dart';

part '../models/invite_musician_dialog_models.dart';
part 'invite_musician_dialog_logic.dart';
part '../ui/widgets/invite_musician_dialog_widgets.dart';

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
      builder: (context, _) => _InviteMusicianDialogView(
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
        builder: (context) => _InviteCreatedDialog(link: link, target: target),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear la invitación: $error')),
      );
    }
  }
}
