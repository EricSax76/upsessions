import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.role,
    required this.onTap,
  });

  final String groupId;
  final String groupName;
  final String role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(context, role);
    final initials = _initialsFromName(groupName);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () async {
          await Clipboard.setData(ClipboardData(text: groupId));
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ID del grupo copiado')));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withAlpha(32),
                child: Text(
                  initials,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rol: ${_roleLabel(role)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _roleLabel(role),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _roleLabel(String role) {
  switch (role) {
    case 'owner':
      return 'Dueño';
    case 'admin':
      return 'Admin';
    default:
      return 'Miembro';
  }
}

Color _roleColor(BuildContext context, String role) {
  final scheme = Theme.of(context).colorScheme;
  switch (role) {
    case 'owner':
      return scheme.secondary;
    case 'admin':
      return scheme.tertiary;
    default:
      return scheme.primary;
  }
}

String _initialsFromName(String value) {
  final cleaned = value.trim();
  if (cleaned.isEmpty) return 'G';
  final parts = cleaned.split(RegExp(r'\s+'));
  if (parts.length == 1) return _firstLetter(parts.first);
  final first = _firstLetter(parts.first);
  final last = _firstLetter(parts.last);
  return '$first$last';
}

String _firstLetter(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.substring(0, 1).toUpperCase();
}
