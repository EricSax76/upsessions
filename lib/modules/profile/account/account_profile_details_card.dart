import 'package:flutter/material.dart';

import 'account_field.dart';

class AccountProfileDetailsCard extends StatelessWidget {
  const AccountProfileDetailsCard({
    super.key,
    required this.bio,
    required this.location,
    required this.skills,
    required this.links,
  });

  final String bio;
  final String location;
  final List<String> skills;
  final Map<String, String> links;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles del perfil',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            AccountField(label: 'Biografía', value: bio),
            const Divider(),
            AccountField(label: 'Ubicación', value: location),
            const Divider(),
            AccountField(
              label: 'Habilidades',
              value: skills.isNotEmpty
                  ? skills.join(', ')
                  : 'Sin habilidades registradas',
            ),
            const Divider(),
            AccountField(
              label: 'Enlaces',
              value: links.isNotEmpty
                  ? links.entries.map((e) => '${e.key}: ${e.value}').join('\n')
                  : 'Sin enlaces',
            ),
          ],
        ),
      ),
    );
  }
}
