import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../cubits/create_group_cubit.dart';
import '../../cubits/create_group_state.dart';
import 'create_group_dialog_content.dart';
import 'photo_options_sheet.dart';

const _dialogMaxWidth = 520.0;

class CreateGroupDialogView extends StatelessWidget {
  const CreateGroupDialogView({
    super.key,
    required this.nameController,
    required this.genreController,
    required this.link1Controller,
    required this.link2Controller,
    required this.descriptionController,
    required this.cityController,
    required this.onCancel,
    required this.onSubmit,
    required this.canSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController genreController;
  final TextEditingController link1Controller;
  final TextEditingController link2Controller;
  final TextEditingController descriptionController;
  final TextEditingController cityController;
  final VoidCallback onCancel;
  final VoidCallback? onSubmit;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cubit = context.read<CreateGroupCubit>();

    return BlocBuilder<CreateGroupCubit, CreateGroupState>(
      builder: (context, state) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.groups_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(loc.rehearsalsSidebarCreateGroupTitle),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
            child: SingleChildScrollView(
              child: CreateGroupDialogContent(
                state: state,
                nameController: nameController,
                genreController: genreController,
                link1Controller: link1Controller,
                link2Controller: link2Controller,
                descriptionController: descriptionController,
                cityController: cityController,
                onShowPhotoOptions: () =>
                    _showPhotoOptions(context, cubit, state),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: onCancel, child: Text(loc.cancel)),
            FilledButton(
              onPressed: canSubmit && !state.isPickingPhoto ? onSubmit : null,
              child: Text(loc.create),
            ),
          ],
        );
      },
    );
  }

  void _showPhotoOptions(
    BuildContext context,
    CreateGroupCubit cubit,
    CreateGroupState state,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => PhotoOptionsSheet(
        hasPhoto: state.photoBytes != null,
        onPickGallery: () => cubit.pickPhoto(ImageSource.gallery),
        onPickCamera: () => cubit.pickPhoto(ImageSource.camera),
        onRemove: cubit.clearPhoto,
      ),
    );
  }
}
