import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locator/locator.dart';
import '../../../../modules/auth/data/auth_repository.dart';
import '../../data/events_repository.dart';
import '../cubit/events_page_cubit.dart';
import '../widgets/event_form_card.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventsPageCubit(repository: locate<EventsRepository>()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Crear evento')),
          body: BlocListener<EventsPageCubit, EventsPageState>(
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
              child: EventFormCard(
                ownerId: locate<AuthRepository>().currentUser?.id,
                onGenerateDraft: (event) {
                  context.read<EventsPageCubit>().generateDraft(event);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
