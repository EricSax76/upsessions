import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/widgets/dialog_header.dart';
import '../../cubits/invite_musician_state.dart';
import '../../../musicians/models/musician_entity.dart';

class InviteMusicianDialogView extends StatelessWidget {
  const InviteMusicianDialogView({
    super.key,
    required this.searchController,
    required this.state,
    required this.onQueryChanged,
    required this.onInviteTap,
  });

  final TextEditingController searchController;
  final InviteMusicianState state;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MusicianEntity> onInviteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AlertDialog(
      title: const DialogHeader(
        icon: Icons.person_add_alt_1_outlined,
        title: 'Agregar músico',
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre',
                hintText: 'Ej. ana',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onQueryChanged,
            ),
            const SizedBox(height: 12),
            InviteSearchBody(
              state: state,
              theme: theme,
              scheme: scheme,
              onInviteTap: onInviteTap,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}



class InviteSearchBody extends StatelessWidget {
  const InviteSearchBody({
    super.key,
    required this.state,
    required this.theme,
    required this.scheme,
    required this.onInviteTap,
  });

  final InviteMusicianState state;
  final ThemeData theme;
  final ColorScheme scheme;
  final ValueChanged<MusicianEntity> onInviteTap;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }

    if (!state.hasQuery) {
      return Text(
        'Escribe al menos 1 carácter.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );
    }

    if (!state.hasResults) {
      return Text(
        'Sin resultados.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );
    }

    return InviteResultsList(
      results: state.results,
      scheme: scheme,
      onInviteTap: onInviteTap,
    );
  }
}

class InviteResultsList extends StatelessWidget {
  const InviteResultsList({
    super.key,
    required this.results,
    required this.scheme,
    required this.onInviteTap,
  });

  final List<MusicianEntity> results;
  final ColorScheme scheme;
  final ValueChanged<MusicianEntity> onInviteTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final target = results[index];
          return InviteResultTile(
            target: target,
            scheme: scheme,
            onTap: () => onInviteTap(target),
          );
        },
      ),
    );
  }
}

class InviteResultTile extends StatelessWidget {
  const InviteResultTile({
    super.key,
    required this.target,
    required this.scheme,
    required this.onTap,
  });

  final MusicianEntity target;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: scheme.surfaceContainerHighest,
        foregroundColor: scheme.onSurface,
        child: Text(
          target.name.trim().isEmpty
              ? '?'
              : target.name.trim().substring(0, 1).toUpperCase(),
        ),
      ),
      title: Text(target.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        target.ownerId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.link, color: scheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

class InviteCreatedDialog extends StatelessWidget {
  const InviteCreatedDialog({super.key, required this.link, required this.target});

  final String link;
  final MusicianEntity target;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle_outline, color: scheme.tertiary),
          const SizedBox(width: 8),
          const Text('Invitación creada'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Para: ${target.name}'),
          const SizedBox(height: 12),
          SelectableText(link),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _copyLink(context),
            icon: const Icon(Icons.copy),
            label: const Text('Copiar link'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Listo'),
        ),
      ],
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    DialogService.showSuccess(context, 'Link copiado.');
  }
}
