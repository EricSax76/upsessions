import 'package:flutter/material.dart';

import 'package:upsessions/features/contacts/ui/widgets/contacts_view.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({
    super.key,
    required this.chatRepository,
  });

  final ChatRepository chatRepository;

  @override
  Widget build(BuildContext context) {
    return ContactsView(chatRepository: chatRepository);
  }
}
