import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../cubits/my_studio_cubit.dart';
import '../../../cubits/studios_state.dart';
import '../../../models/room_entity.dart';
import 'photo_picker_section.dart';

/// Formulario de creación / edición de sala.
///
/// Responsabilidad: estado de los campos, coordinación del guardado
/// (subida de fotos → construcción de [RoomEntity] → llamada al cubit).
class RoomFormBody extends StatefulWidget {
  const RoomFormBody({super.key, required this.studioId, this.room});

  final String studioId;
  final RoomEntity? room;

  @override
  State<RoomFormBody> createState() => _RoomFormBodyState();
}

class _RoomFormBodyState extends State<RoomFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _photoPickerKey = GlobalKey<PhotoPickerSectionState>();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    if (room != null) {
      _nameController.text = room.name;
      _capacityController.text = room.capacity.toString();
      _sizeController.text = room.size;
      _priceController.text = room.pricePerHour.toString();
      _equipmentController.text = room.equipment.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final roomId = widget.room?.id ?? const Uuid().v4();
    final photos = await _photoPickerKey.currentState!.uploadAndGetPhotos(
      studioId: widget.studioId,
      roomId: roomId,
    );

    setState(() => _saving = false);

    final equipment = _equipmentController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final room = RoomEntity(
      id: roomId,
      studioId: widget.studioId,
      name: _nameController.text,
      capacity: int.tryParse(_capacityController.text) ?? 0,
      size: _sizeController.text,
      pricePerHour: double.tryParse(_priceController.text) ?? 0.0,
      equipment: equipment,
      amenities: [],
      photos: photos,
    );

    if (mounted) {
      context.read<MyStudioCubit>().createRoom(room);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyStudioCubit, StudiosState>(
      builder: (context, state) {
        final isLoading = state.status == StudiosStatus.loading || _saving;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.room == null ? 'Add Room' : 'Edit Room',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Room Name'),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _capacityController,
                            decoration: const InputDecoration(
                              labelText: 'Capacity (ppl)',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _sizeController,
                            decoration: const InputDecoration(
                              labelText: 'Size (e.g. 4x5m)',
                            ),
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price per Hour (€)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _equipmentController,
                      decoration: const InputDecoration(
                        labelText: 'Equipment (comma separated)',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    PhotoPickerSection(
                      key: _photoPickerKey,
                      initialPhotos: widget.room?.photos ?? [],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? CircularProgressIndicator(
                              color:
                                  Theme.of(context).colorScheme.onPrimary,
                            )
                          : Text(
                              widget.room == null
                                  ? 'Create Room'
                                  : 'Save Changes',
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
