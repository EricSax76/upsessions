import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/events/ui/widgets/event_form_card.dart';
import '../../cubits/event_manager_auth_cubit.dart';
import '../../cubits/manager_event_form_cubit.dart';
import '../../cubits/manager_event_form_state.dart';

class ManagerEventFormPage extends StatelessWidget {
  const ManagerEventFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final managerId = context.read<EventManagerAuthCubit>().state.manager?.id;

    return BlocListener<ManagerEventFormCubit, ManagerEventFormState>(
      listenWhen: (previous, current) => previous.success != current.success,
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento guardado exitosamente.')),
          );
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Evento'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: BlocBuilder<ManagerEventFormCubit, ManagerEventFormState>(
                builder: (context, state) {
                  return IgnorePointer(
                    ignoring: state.isSaving,
                    child: Column(
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
                        EventFormCard(
                          ownerId: managerId,
                          onGenerateDraft: (event) {
                            context.read<ManagerEventFormCubit>().saveEvent(event);
                          },
                        ),
                      ],
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
