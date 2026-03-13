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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSubmitting) return;

    final managerId =
        context.read<EventManagerAuthCubit>().state.manager?.id ?? '';
    final request = MusicianRequestEntity(
      id: '',
      managerId: managerId,
      musicianId: widget.musicianId,
      status: RequestStatus.pending,
      message: message,
      createdAt: DateTime.now(),
    );

    setState(() => _isSubmitting = true);
    final cubit = context.read<MusicianRequestsCubit>();
    await cubit.sendRequest(request);

    if (!mounted) return;

    final error = cubit.state.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar la solicitud: $error')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitud enviada correctamente.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: AlertDialog(
        title: Text('Solicitar a ${widget.musicianName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Envíale un mensaje directo para invitarlo a tocar en tu evento o jam session:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 4,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                hintText: 'Hola, me encanta tu estilo. Estoy organizando...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: _isSubmitting ? null : _sendRequest,
            child: Text(_isSubmitting ? 'Enviando...' : 'Enviar Solicitud'),
          ),
        ],
      ),
    );
  }
}
