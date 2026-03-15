import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../cubits/my_studio_cubit.dart';
import '../../../cubits/room_form_cubit.dart';
import '../../../cubits/room_form_state.dart';
import '../../../cubits/studios_state.dart';
import '../../../cubits/studios_status.dart';
import '../../../models/room_entity.dart';
import '../../../ui/forms/room_form_draft.dart';
import 'photo_picker_section.dart';

/// Formulario de creación / edición de sala.
///
/// La UI solo renderiza campos/validación. El flujo de submit vive en
/// [RoomFormCubit] (upload de fotos + composición de entidad + dispatch).
class RoomFormBody extends StatefulWidget {
  const RoomFormBody({super.key, required this.studioId, this.room});

  final String studioId;
  final RoomEntity? room;

  @override
  State<RoomFormBody> createState() => _RoomFormBodyState();
}

class _RoomFormBodyState extends State<RoomFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _photoPickerKey = GlobalKey<PhotoPickerSectionState>();

  late final RoomFormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = RoomFormCubit(
      studioCubit: context.read<MyStudioCubit>(),
      initialRoom: widget.room,
    );
  }

  @override
  void dispose() {
    _formCubit.close();
    super.dispose();
  }

  String? _requiredValidator(String? value, AppLocalizations loc) {
    return value?.trim().isNotEmpty == true ? null : loc.roomFormRequiredField;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await _formCubit.submit(
      studioId: widget.studioId,
      existingRoom: widget.room,
      uploadPhotos: (roomId) async {
        final pickerState = _photoPickerKey.currentState;
        if (pickerState == null) {
          return widget.room?.photos ?? const <String>[];
        }
        return pickerState.uploadAndGetPhotos(
          studioId: widget.studioId,
          roomId: roomId,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocProvider<RoomFormCubit>.value(
      value: _formCubit,
      child: BlocListener<RoomFormCubit, RoomFormState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? loc.roomFormSaveError),
            ),
          );
        },
        child: BlocBuilder<MyStudioCubit, StudiosState>(
          builder: (context, studioState) {
            return BlocBuilder<RoomFormCubit, RoomFormState>(
              builder: (context, formState) {
                final draft = context.read<RoomFormCubit>().draft;
                final isLoading =
                    studioState.status == StudiosStatus.loading ||
                    formState.isSubmitting;

                return _RoomFormView(
                  formKey: _formKey,
                  draft: draft,
                  photoPickerKey: _photoPickerKey,
                  isEditing: widget.room != null,
                  initialPhotos: widget.room?.photos ?? const [],
                  isLoading: isLoading,
                  requiredValidator: (value) => _requiredValidator(value, loc),
                  onAccessibilityChanged: (value) =>
                      setState(() => draft.isAccessible = value),
                  onIsActiveChanged: (value) =>
                      setState(() => draft.isActive = value),
                  onSubmit: _submit,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RoomFormView extends StatelessWidget {
  const _RoomFormView({
    required this.formKey,
    required this.draft,
    required this.photoPickerKey,
    required this.isEditing,
    required this.initialPhotos,
    required this.isLoading,
    required this.requiredValidator,
    required this.onAccessibilityChanged,
    required this.onIsActiveChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final RoomFormDraft draft;
  final GlobalKey<PhotoPickerSectionState> photoPickerKey;
  final bool isEditing;
  final List<String> initialPhotos;
  final bool isLoading;
  final FormFieldValidator<String> requiredValidator;
  final ValueChanged<bool> onAccessibilityChanged;
  final ValueChanged<bool> onIsActiveChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? loc.roomFormEditTitle : loc.roomFormAddTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: draft.nameController,
                  decoration: InputDecoration(labelText: loc.roomFormNameLabel),
                  validator: requiredValidator,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: draft.capacityController,
                        decoration: InputDecoration(
                          labelText: loc.roomFormCapacityLabel,
                        ),
                        keyboardType: TextInputType.number,
                        validator: requiredValidator,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: draft.sizeController,
                        decoration: InputDecoration(
                          labelText: loc.roomFormSizeLabel,
                        ),
                        validator: requiredValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: draft.priceController,
                  decoration: InputDecoration(
                    labelText: loc.roomFormPricePerHourLabel,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: requiredValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: draft.equipmentController,
                  decoration: InputDecoration(
                    labelText: loc.roomFormEquipmentLabel,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                PhotoPickerSection(
                  key: photoPickerKey,
                  initialPhotos: initialPhotos,
                ),
                const SizedBox(height: 32),
                Text(
                  loc.roomFormSectionConfig,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: draft.minBookingHoursController,
                  decoration: InputDecoration(
                    labelText: loc.roomFormMinBookingHoursLabel,
                    helperText: loc.roomFormMinBookingHoursHelp,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: draft.maxDecibelsController,
                  decoration: InputDecoration(
                    labelText: loc.roomFormMaxDecibelsLabel,
                    helperText: loc.roomFormMaxDecibelsHelp,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: draft.ageRestrictionController,
                  decoration: InputDecoration(
                    labelText: loc.roomFormAgeRestrictionLabel,
                    helperText: loc.roomFormAgeRestrictionHelp,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                Text(
                  loc.roomFormSectionPolicies,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: draft.cancellationPolicyController,
                  decoration: InputDecoration(
                    labelText: loc.roomFormCancellationPolicyLabel,
                    helperText: loc.roomFormCancellationPolicyHelp,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(loc.roomFormAccessibleTitle),
                  subtitle: Text(loc.roomFormAccessibleSubtitle),
                  value: draft.isAccessible,
                  onChanged: onAccessibilityChanged,
                ),
                SwitchListTile(
                  title: Text(loc.roomFormActiveTitle),
                  subtitle: Text(loc.roomFormActiveSubtitle),
                  value: draft.isActive,
                  onChanged: onIsActiveChanged,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : Text(
                            isEditing
                                ? loc.saveAction
                                : loc.roomFormCreateAction,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
