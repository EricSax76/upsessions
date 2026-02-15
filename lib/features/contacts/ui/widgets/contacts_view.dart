import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/liked_musicians_cubit.dart';
import '../../cubits/liked_musicians_state.dart';
import '../widgets/contact_card.dart';
import 'contacts_header.dart';
import 'empty_contacts.dart';
import '../../../messaging/repositories/chat_repository.dart';

class ContactsView extends StatelessWidget {
  const ContactsView({super.key, required this.chatRepository});

  final ChatRepository chatRepository;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LikedMusiciansCubit, LikedMusiciansState>(
      builder: (context, state) {
        final contacts = state.sortedContacts;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContactsHeader(total: contacts.length),
                const SizedBox(height: 24),
                if (contacts.isEmpty)
                  const EmptyContacts()
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: contacts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ContactCard(
                          musician: contact,
                          chatRepository: chatRepository,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
