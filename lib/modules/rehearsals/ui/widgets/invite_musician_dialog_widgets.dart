part of '../../controllers/invite_musician_dialog.dart';

class _InviteMusicianDialogView extends StatelessWidget {
  const _InviteMusicianDialogView({
    required this.controller,
    required this.state,
    required this.onInviteTap,
  });

  final InviteMusicianDialogController controller;
  final InviteMusicianDialogState state;
  final ValueChanged<MusicianEntity> onInviteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AlertDialog(
      title: _InviteDialogTitle(scheme: scheme),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre',
                hintText: 'Ej. ana',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: controller.onQueryChanged,
            ),
            const SizedBox(height: 12),
            _InviteSearchBody(
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

class _InviteDialogTitle extends StatelessWidget {
  const _InviteDialogTitle({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person_add_alt_1_outlined,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        const Text('Agregar músico'),
      ],
    );
  }
}

class _InviteSearchBody extends StatelessWidget {
  const _InviteSearchBody({
    required this.state,
    required this.theme,
    required this.scheme,
    required this.onInviteTap,
  });

  final InviteMusicianDialogState state;
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

    return _InviteResultsList(
      results: state.results,
      scheme: scheme,
      onInviteTap: onInviteTap,
    );
  }
}

class _InviteResultsList extends StatelessWidget {
  const _InviteResultsList({
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
          return _InviteResultTile(
            target: target,
            scheme: scheme,
            onTap: () => onInviteTap(target),
          );
        },
      ),
    );
  }
}

class _InviteResultTile extends StatelessWidget {
  const _InviteResultTile({
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

class _InviteCreatedDialog extends StatelessWidget {
  const _InviteCreatedDialog({required this.link, required this.target});

  final InviteLinkData link;
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
          SelectableText(link.url),
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
    await Clipboard.setData(ClipboardData(text: link.url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link copiado.')));
  }
}
