import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/musician_request_entity.dart';
import '../../../cubits/musician_requests_cubit.dart';
import '../../../cubits/event_manager_auth_cubit.dart';

class MusicianRequestDialog extends StatefulWidget {
  const MusicianRequestDialog({
    super.key,
    required this.musicianId,
    required this.musicianName,
  });

  final String musicianId;
  final String musicianName;

  @override
  State<MusicianRequestDialog> createState() => _MusicianRequestDialogState();
}

class _MusicianRequestDialogState extends State<MusicianRequestDialog> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendRequest() {
    if (_messageController.text.trim().isEmpty) return;

    final managerId = context.read<EventManagerAuthCubit>().state.manager?.id ?? '';
    final request = MusicianRequestEntity(
      id: '',
      managerId: managerId,
      musicianId: widget.musicianId,
      status: RequestStatus.pending,
      message: _messageController.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<MusicianRequestsCubit>().sendRequest(request);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Solicitar a ${widget.musicianName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Envíale un mensaje directo para invitarlo a tocar en tu evento o jam session:'),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Hola, me encanta tu estilo. Estoy organizando...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _sendRequest,
          child: const Text('Enviar Solicitud'),
        ),
      ],
    );
  }
}
