import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../repositories/groups_repository.dart';
import '../../models/group_dtos.dart';
import 'group_rehearsals_page.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      child: DefaultTabController(
        length: 2,
        child: _GroupPageView(groupId: groupId),
      ),
    );
  }
}

class _GroupPageView extends StatelessWidget {
  const _GroupPageView({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final groupsRepository = locate<GroupsRepository>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<GroupDoc>(
      stream: groupsRepository.watchGroup(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final group = snapshot.data;
        if (group == null) {
          return const Center(child: Text('Grupo no encontrado'));
        }

        return Column(
          children: [
            // Header con Info del Grupo
            _GroupHeader(group: group),
            
            // Navegación (Tabs)
            Material(
              color: colorScheme.surface,
              child: TabBar(
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Ensayos', icon: Icon(Icons.event_available)),
                  Tab(text: 'Información', icon: Icon(Icons.info_outline)),
                ],
              ),
            ),
            
            // Contenido de los Tabs
            Expanded(
              child: TabBarView(
                children: [
                  // Tab Ensayos: Usamos la vista existente pero sin su propio header
                  GroupRehearsalsView(
                    groupId: groupId,
                    showHeader: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  ),
                  
                  // Tab Información
                  _GroupInfoTab(group: group),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final GroupDoc group;

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final groupsRepository = locate<GroupsRepository>();
    final picker = ImagePicker();
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subiendo imagen...')),
      );

      final bytes = await image.readAsBytes();
      final ext = image.path.split('.').last;

      await groupsRepository.updateGroupPhoto(
        groupId: group.id,
        photoBytes: bytes,
        photoFileExtension: ext,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto del grupo actualizada')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir imagen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
                backgroundImage: group.photoUrl.isNotEmpty 
                    ? NetworkImage(group.photoUrl) 
                    : null,
                child: group.photoUrl.isEmpty
                    ? Icon(Icons.group, size: 40, color: colorScheme.onPrimary)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickAndUploadImage(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            group.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (group.genre.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              group.genre,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupInfoTab extends StatelessWidget {
  const _GroupInfoTab({required this.group});

  final GroupDoc group;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (group.link1.isNotEmpty || group.link2.isNotEmpty) ...[
          Text(
            'Enlaces y Redes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (group.link1.isNotEmpty)
            _InfoTile(icon: Icons.link, label: group.link1),
          if (group.link2.isNotEmpty)
            _InfoTile(icon: Icons.link, label: group.link2),
          const SizedBox(height: 24),
        ],
        Text(
          'Configuración',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _InfoTile(
          icon: Icons.admin_panel_settings_outlined, 
          label: 'ID del grupo: ${group.id}',
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
