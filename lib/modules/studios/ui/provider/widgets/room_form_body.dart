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

  // Normativa
  final _minBookingHoursController = TextEditingController();
  final _maxDecibelsController = TextEditingController();
  final _ageRestrictionController = TextEditingController();
  final _cancellationPolicyController = TextEditingController();
  bool _isAccessible = false;
  bool _isActive = true;

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
      // Normativa
      _minBookingHoursController.text = room.minBookingHours.toString();
      if (room.maxDecibels != null) {
        _maxDecibelsController.text = room.maxDecibels.toString();
      }
      if (room.ageRestriction != null) {
        _ageRestrictionController.text = room.ageRestriction.toString();
      }
      if (room.cancellationPolicy != null) {
        _cancellationPolicyController.text = room.cancellationPolicy!;
      }
      _isAccessible = room.isAccessible;
      _isActive = room.isActive;
    } else {
      _minBookingHoursController.text = '1';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _equipmentController.dispose();
    _minBookingHoursController.dispose();
    _maxDecibelsController.dispose();
    _ageRestrictionController.dispose();
    _cancellationPolicyController.dispose();
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

    final maxDecibelsText = _maxDecibelsController.text.trim();
    final ageRestrictionText = _ageRestrictionController.text.trim();
    final cancellationText = _cancellationPolicyController.text.trim();

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
      // Normativa
      minBookingHours:
          int.tryParse(_minBookingHoursController.text) ?? 1,
      maxDecibels: maxDecibelsText.isNotEmpty
          ? double.tryParse(maxDecibelsText)
          : null,
      ageRestriction: ageRestrictionText.isNotEmpty
          ? int.tryParse(ageRestrictionText)
          : null,
      cancellationPolicy:
          cancellationText.isNotEmpty ? cancellationText : null,
      isAccessible: _isAccessible,
      isActive: _isActive,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Datos basicos ──────────────────────────
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

                    // ── Configuración de sala ─────────────────
                    const SizedBox(height: 32),
                    Text('Configuración de sala',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _minBookingHoursController,
                      decoration: const InputDecoration(
                        labelText: 'Horas mínimas por reserva',
                        helperText: 'Contractual — mínimo de horas',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxDecibelsController,
                      decoration: const InputDecoration(
                        labelText: 'Decibelios máximos (dB)',
                        helperText:
                            'Ordenanzas municipales de ruido — nivel máximo',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageRestrictionController,
                      decoration: const InputDecoration(
                        labelText: 'Restricción de edad mínima',
                        helperText:
                            'LOPDGDD Art. 7 — edad mínima para usar la sala',
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    // ── Políticas ─────────────────────────────
                    const SizedBox(height: 32),
                    Text('Políticas',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cancellationPolicyController,
                      decoration: const InputDecoration(
                        labelText: 'Política de cancelación',
                        helperText:
                            'Directiva 2011/83/UE — cancelación y devolución',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Accesibilidad'),
                      subtitle: const Text(
                          'RD 1/2013 — acceso movilidad reducida'),
                      value: _isAccessible,
                      onChanged: (v) =>
                          setState(() => _isAccessible = v),
                    ),
                    SwitchListTile(
                      title: const Text('Sala activa'),
                      subtitle:
                          const Text('Visible para reservas'),
                      value: _isActive,
                      onChanged: (v) =>
                          setState(() => _isActive = v),
                    ),

                    // ── Submit ─────────────────────────────────
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
