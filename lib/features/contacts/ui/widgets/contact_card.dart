import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../messaging/repositories/chat_repository.dart';
import '../../cubits/contact_card_cubit.dart';
import '../../cubits/contact_card_state.dart';
import '../../models/liked_musician.dart';
import 'contact_card_actions.dart';
import 'contact_card_header.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.musician});

  final LikedMusician musician;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => ContactCardCubit(chatRepository: locate<ChatRepository>()),
      child: BlocListener<ContactCardCubit, ContactCardState>(
        listener: (context, state) {
          if (state.status == ContactCardStatus.success &&
              state.threadId != null) {
            context.push(AppRoutes.messagesThreadPath(state.threadId!));
          } else if (state.status == ContactCardStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No se pudo iniciar el chat: ${state.errorMessage}',
                ),
              ),
            );
          }
        },
        child: Builder(
          builder: (context) {
            final cubit = context.read<ContactCardCubit>();

            void viewProfile() {
              final entity = cubit.toMusicianEntity(musician);
              context.push(
                AppRoutes.musicianDetailPath(
                  musicianId: entity.id,
                  musicianName: entity.name,
                ),
                extra: entity,
              );
            }

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              color: colorScheme.surface,
              child: InkWell(
                onTap: viewProfile,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ContactCardHeader(musician: musician),
                      const SizedBox(height: 16),
                      BlocBuilder<ContactCardCubit, ContactCardState>(
                        builder: (context, state) {
                          return ContactCardActions(
                            onViewProfile: viewProfile,
                            onContact: () => cubit.contact(musician),
                            isContacting: state.isContacting,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
