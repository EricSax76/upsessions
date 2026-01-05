import 'package:flutter/material.dart';

import '../../controllers/liked_musicians_controller.dart';
import 'contact_card.dart';
import 'contacts_header.dart';
import 'empty_contacts.dart';

class ContactsView extends StatelessWidget {
  const ContactsView({super.key, required this.controller});

  final LikedMusiciansController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final contacts = controller.contacts;
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
                      separatorBuilder: (_, unused) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ContactCard(musician: contact);
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
