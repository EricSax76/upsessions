import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/create_group_cubit.dart';
import '../../models/create_group_draft.dart';
import 'create_group_dialog_view.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _nameController = TextEditingController();
  final _genreController = TextEditingController();
  final _link1Controller = TextEditingController();
  final _link2Controller = TextEditingController();

  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateCanSubmit);
  }

  void _updateCanSubmit() {
    final canSubmit = _nameController.text.trim().isNotEmpty;
    if (canSubmit != _canSubmit) {
      setState(() {
        _canSubmit = canSubmit;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genreController.dispose();
    _link1Controller.dispose();
    _link2Controller.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    final cubit = context.read<CreateGroupCubit>();
    final draft = CreateGroupDraft(
      name: _nameController.text.trim(),
      genre: _genreController.text.trim(),
      link1: _link1Controller.text.trim(),
      link2: _link2Controller.text.trim(),
      photoBytes: cubit.state.photoBytes,
      photoFileExtension: cubit.state.photoExtension,
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateGroupCubit(imagePicker: ImagePicker()),
      child: Builder(
        builder: (context) {
          return CreateGroupDialogView(
            nameController: _nameController,
            genreController: _genreController,
            link1Controller: _link1Controller,
            link2Controller: _link2Controller,
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: () => _handleSubmit(context),
            canSubmit: _canSubmit,
          );
        },
      ),
    );
  }
}
