import 'package:flutter/material.dart';

import 'create_group_dialog_controller.dart';
import '../models/create_group_dialog_view.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  late final CreateGroupDialogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreateGroupDialogController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CreateGroupDialogView(
      controller: _controller,
      onCancel: () => Navigator.of(context).pop(),
      onSubmit: (draft) => Navigator.of(context).pop(draft),
    );
  }
}
