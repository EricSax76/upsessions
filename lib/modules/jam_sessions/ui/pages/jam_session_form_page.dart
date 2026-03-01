import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../event_manager/cubits/event_manager_auth_cubit.dart';
import '../../cubits/jam_session_form_cubit.dart';
import '../../cubits/jam_session_form_state.dart';
import '../../models/jam_session_entity.dart';

class JamSessionFormPage extends StatefulWidget {
  const JamSessionFormPage({super.key});

  @override
  State<JamSessionFormPage> createState() => _JamSessionFormPageState();
}

class _JamSessionFormPageState extends State<JamSessionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      final managerId = context.read<EventManagerAuthCubit>().state.manager?.id ?? '';
      final session = JamSessionEntity(
        id: '',
        ownerId: managerId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: DateTime.now().add(const Duration(days: 7)), // Dummy date for now
        time: '20:00',
        location: _locationController.text.trim(),
        city: _cityController.text.trim(),
      );

      context.read<JamSessionFormCubit>().saveSession(session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JamSessionFormCubit, JamSessionFormState>(
      listenWhen: (previous, current) => previous.success != current.success,
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jam session guardada exitosamente.')),
          );
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Jam Session'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: BlocBuilder<JamSessionFormCubit, JamSessionFormState>(
                builder: (context, state) {
                  return IgnorePointer(
                    ignoring: state.isSaving,
                    child: AppCard(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.isSaving)
                              const LinearProgressIndicator(),
                            if (state.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.error),
                                ),
                              ),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(labelText: 'Título corto'),
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(labelText: 'Descripción'),
                              maxLines: 3,
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(labelText: 'Ciudad'),
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(labelText: 'Lugar exacto (Google Maps / Calle)'),
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _saveSession,
                                child: const Text('Guardar Borrador'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
