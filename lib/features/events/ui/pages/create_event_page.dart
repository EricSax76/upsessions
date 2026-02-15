import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locator/locator.dart';
import '../../../../modules/auth/repositories/auth_repository.dart';
import '../../repositories/events_repository.dart';
import '../../cubits/events_page_cubit.dart';
import '../widgets/event_form_card.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventsPageCubit(repository: locate<EventsRepository>()),
      child: BlocListener<EventsPageCubit, EventsPageState>(
        listenWhen: (previous, current) =>
            previous.draftSavedCount != current.draftSavedCount,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ficha de evento lista para compartir.'),
            ),
          );
          context.pop();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crear evento',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  EventFormCard(
                    ownerId: locate<AuthRepository>().currentUser?.id,
                    onGenerateDraft: (event) {
                      context.read<EventsPageCubit>().generateDraft(event);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
