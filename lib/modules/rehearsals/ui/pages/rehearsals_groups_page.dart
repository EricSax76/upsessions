import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../cubits/group_membership_entity.dart';
import '../../repositories/groups_repository.dart';
import '../widgets/rehearsals_groups_widgets.dart';

class RehearsalsGroupsPage extends StatelessWidget {
  const RehearsalsGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserShellPage(child: _RehearsalsGroupsView());
  }
}

class _RehearsalsGroupsView extends StatelessWidget {
  const _RehearsalsGroupsView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: const TabBar(
              tabs: [
                Tab(text: 'Mis Grupos'),
                Tab(text: 'Agenda'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(children: [_GroupsTab(), _AgendaTab()]),
          ),
        ],
      ),
    );
  }
}

class _GroupsTab extends StatefulWidget {
  const _GroupsTab();

  @override
  State<_GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<_GroupsTab> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(() {
        final next = _searchController.text;
        if (next == _query) return;
        setState(() => _query = next);
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = locate<GroupsRepository>();
    return StreamBuilder<List<GroupMembershipEntity>>(
      stream: repository.watchMyGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        final groups = snapshot.data ?? const <GroupMembershipEntity>[];
        final visibleGroups = _filterGroups(groups, _query)
          ..sort(_compareGroups);

        return RefreshIndicator(
          onRefresh: () async {
            await repository.authRepository.refreshIdToken();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _StaggeredEntry(
                index: 0,
                child: RehearsalsGroupsHeader(
                  groupCount: groups.length,
                  visibleCount: visibleGroups.length,
                ),
              ),
              const SizedBox(height: 16),
              _StaggeredEntry(
                index: 1,
                child: RehearsalsGroupsActions(
                  onGoToGroup: () => _showGoToGroupDialog(context),
                  onCreateGroup: () =>
                      _showCreateGroupDialog(context, repository),
                ),
              ),
              const SizedBox(height: 16),
              _StaggeredEntry(
                index: 2,
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Buscar grupos',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.trim().isEmpty
                        ? null
                        : IconButton(
                            onPressed: _searchController.clear,
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (snapshot.hasError)
                _StaggeredEntry(
                  index: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_off_outlined,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'No pudimos cargar tus grupos.',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () async {
                                  await repository.authRepository
                                      .refreshIdToken();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (groups.isEmpty)
                const _StaggeredEntry(
                  index: 3,
                  child: RehearsalsGroupsEmptyState(),
                )
              else if (visibleGroups.isEmpty)
                _StaggeredEntry(
                  index: 3,
                  child: EmptyStateCard(
                    icon: Icons.search_off_outlined,
                    title: 'No hay resultados',
                    subtitle: 'Prueba con otro nombre o limpia la búsqueda.',
                    trailing: TextButton(
                      onPressed: _searchController.clear,
                      child: const Text('Limpiar'),
                    ),
                  ),
                )
              else
                ...visibleGroups.asMap().entries.map(
                  (entry) => _StaggeredEntry(
                    index: 3 + entry.key,
                    child: GroupCard(
                      groupId: entry.value.groupId,
                      groupName: entry.value.groupName,
                      role: entry.value.role,
                      onTap: () =>
                          context.go(AppRoutes.groupPage(entry.value.groupId)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateGroupDialog(
    BuildContext context,
    GroupsRepository repository,
  ) async {
    final result = await showDialog<CreateGroupDraft>(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    );
    if (result == null || result.name.trim().isEmpty) {
      return;
    }
    try {
      final groupId = await repository.createGroup(
        name: result.name,
        genre: result.genre,
        link1: result.link1,
        link2: result.link2,
        photoBytes: result.photoBytes,
        photoFileExtension: result.photoFileExtension,
      );
      if (!context.mounted) return;
      context.go(AppRoutes.groupPage(groupId));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el grupo: $error')),
      );
    }
  }

  Future<void> _showGoToGroupDialog(BuildContext context) async {
    final controller = TextEditingController();
    final groupId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ir a un grupo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'ID del grupo',
            hintText: 'Ej. 6qDBI5b0LnybgBSF5KHU',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Ir'),
          ),
        ],
      ),
    );
    if (groupId == null || groupId.trim().isEmpty) return;
    if (!context.mounted) return;
    context.go(AppRoutes.groupPage(groupId.trim()));
  }
}

List<GroupMembershipEntity> _filterGroups(
  List<GroupMembershipEntity> groups,
  String query,
) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) return List<GroupMembershipEntity>.from(groups);
  return groups
      .where((group) => group.groupName.toLowerCase().contains(trimmed))
      .toList();
}

int _compareGroups(GroupMembershipEntity a, GroupMembershipEntity b) {
  final ap = _rolePriority(a.role);
  final bp = _rolePriority(b.role);
  if (ap != bp) return ap.compareTo(bp);
  return a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase());
}

int _rolePriority(String role) {
  switch (role) {
    case 'owner':
      return 0;
    case 'admin':
      return 1;
    default:
      return 2;
  }
}

class _AgendaTab extends StatelessWidget {
  const _AgendaTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: EmptyStateCard(
        icon: Icons.calendar_today_outlined,
        title: 'Tu Agenda',
        subtitle: 'Aquí verás tus próximos ensayos de todos tus grupos.',
      ),
    );
  }
}

class _StaggeredEntry extends StatefulWidget {
  final int index;
  final Widget child;
  const _StaggeredEntry({required this.index, required this.child});

  @override
  State<_StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<_StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
