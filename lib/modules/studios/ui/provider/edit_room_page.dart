import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../models/room_entity.dart';
import '../../repositories/studios_repository.dart';
import '../../services/studio_image_service.dart';
import '../../../../core/locator/locator.dart';

class EditRoomPage extends StatefulWidget {
  const EditRoomPage({
    super.key,
    required this.studioId,
    this.room,
  });

  final String studioId;
  final RoomEntity? room;

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();
  final _equipmentController = TextEditingController(); // Comma separated for MVP
  // Photos not implemented for MVP

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _nameController.text = widget.room!.name;
      _capacityController.text = widget.room!.capacity.toString();
      _sizeController.text = widget.room!.size;
      _priceController.text = widget.room!.pricePerHour.toString();
      _equipmentController.text = widget.room!.equipment.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudiosCubit(
        repository: locate<StudiosRepository>(),
        imageService: locate<StudioImageService>(),
      ), // We just need access to repo mainly, or we could pass the cubit
      child: BlocConsumer<StudiosCubit, StudiosState>(
        listener: (context, state) {
          if (state.status == StudiosStatus.success) {
            Navigator.of(context).pop();
          } else if (state.status == StudiosStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error saving room')),
            );
          }
        },
        builder: (context, state) {
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
                        decoration: const InputDecoration(labelText: 'Room Name'),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                           Expanded(
                            child: TextFormField(
                              controller: _capacityController,
                              decoration: const InputDecoration(labelText: 'Capacity (ppl)'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _sizeController,
                              decoration: const InputDecoration(labelText: 'Size (e.g. 4x5m)'),
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price per Hour (€)'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                       const SizedBox(height: 16),
                      TextFormField(
                        controller: _equipmentController,
                        decoration: const InputDecoration(labelText: 'Equipment (comma separated)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                       ElevatedButton(
                        onPressed: state.status == StudiosStatus.loading ? null : () {
                          if (_formKey.currentState?.validate() ?? false) {
                             final equipment = _equipmentController.text
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();
  
                             final room = RoomEntity(
                              id: widget.room?.id ?? const Uuid().v4(),
                              studioId: widget.studioId,
                              name: _nameController.text,
                              capacity: int.tryParse(_capacityController.text) ?? 0,
                              size: _sizeController.text,
                              pricePerHour: double.tryParse(_priceController.text) ?? 0.0,
                              equipment: equipment,
                              amenities: [], // Not implemented for MVP
                              photos: [], // Not implemented for MVP
                             );
                             
                             // Using the cubit to create
                             context.read<StudiosCubit>().createRoom(room);
                          }
                        },
                        child: state.status == StudiosStatus.loading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(widget.room == null ? 'Create Room' : 'Save Changes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
