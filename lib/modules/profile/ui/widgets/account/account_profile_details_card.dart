import 'package:flutter/material.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.badge_outlined, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Detalles del perfil',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailSection(
              context,
              icon: Icons.info_outline,
              label: 'Biografía',
              value: bio.isNotEmpty ? bio : 'Sin biografía',
            ),
            const Divider(height: 32),
            _buildDetailSection(
              context,
              icon: Icons.location_on_outlined,
              label: 'Ubicación',
              value: location.isNotEmpty ? location : 'Sin ubicación',
            ),
            const Divider(height: 32),
            _buildDetailSection(
              context,
              icon: Icons.psychology_outlined,
              label: 'Habilidades',
              value: skills.isNotEmpty
                  ? skills.join(', ')
                  : 'Sin habilidades registradas',
            ),
            const Divider(height: 32),
            _buildDetailSection(
              context,
              icon: Icons.link,
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

  Widget _buildDetailSection(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
