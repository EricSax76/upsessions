import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../../../core/widgets/empty_state_card.dart';
import '../../data/events_repository.dart';
import '../../data/image_upload_service.dart';
import '../../domain/event_entity.dart';
import '../widgets/event_text_template_card.dart';



class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.event});

  final EventEntity event;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late EventEntity _currentEvent;
  bool _isUploadingBanner = false;
  final ImageUploadService _imageUploadService = ImageUploadService();
  final EventsRepository _eventsRepository = EventsRepository();

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  Future<void> _uploadBanner() async {
    debugPrint('🎯 [EventDetail] Iniciando proceso de subida de banner');
    
    setState(() {
      _isUploadingBanner = true;
    });

    try {
      debugPrint('📸 [EventDetail] Llamando a uploadEventBanner con ID: ${_currentEvent.id}');
      final imageUrl = await _imageUploadService.uploadEventBanner(_currentEvent.id);
      
      if (imageUrl != null) {
        debugPrint('✅ [EventDetail] URL recibida: $imageUrl');
        debugPrint('💾 [EventDetail] Guardando evento actualizado en Firestore');
        
        final updatedEvent = _currentEvent.copyWith(bannerImageUrl: imageUrl);
        final savedEvent = await _eventsRepository.saveDraft(updatedEvent);
        
        setState(() {
          _currentEvent = savedEvent;
          _isUploadingBanner = false;
        });

        debugPrint('🎉 [EventDetail] Banner actualizado exitosamente');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Banner actualizado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        debugPrint('⚠️ [EventDetail] No se recibió URL (usuario canceló)');
        setState(() {
          _isUploadingBanner = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [EventDetail] Error al subir banner: $e');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() {
        _isUploadingBanner = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al subir el banner: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Ver detalles',
              textColor: Colors.white,
              onPressed: () {
                debugPrint('Detalles del error: $stackTrace');
              },
            ),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final event = _currentEvent;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = MaterialLocalizations.of(context);
    final dateLabel = loc.formatFullDate(event.start);
    final startTime = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(event.start),
      alwaysUse24HourFormat: true,
    );
    final endTime = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(event.end),
      alwaysUse24HourFormat: true,
    );

    Future<void> copyEventTemplate() async {
      final template = buildEventTextTemplate(context, event);
      await Clipboard.setData(ClipboardData(text: template));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ficha copiada al portapapeles')),
      );
    }

    void showShareComingSoon() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compartir: próximamente')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            tooltip: 'Copiar formato',
            onPressed: copyEventTemplate,
            icon: const Icon(Icons.copy_all_outlined),
          ),
          IconButton(
            tooltip: 'Compartir',
            onPressed: showShareComingSoon,
            icon: const Icon(Icons.share_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 420
              ? 16.0
              : (constraints.maxWidth < 720 ? 20.0 : 24.0);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                children: [
                  _EventBanner(
                    imageUrl: event.bannerImageUrl,
                    isUploading: _isUploadingBanner,
                    onUpload: _uploadBanner,
                    eventTitle: event.title,
                  ),
                  if (event.bannerImageUrl != null) const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.event_available_outlined,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateLabel,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$startTime - $endTime',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${event.venue} · ${event.city}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _InfoPill(
                                icon: Icons.group_outlined,
                                label: '${event.capacity} personas',
                              ),
                              if (event.ticketInfo.trim().isNotEmpty)
                                _InfoPill(
                                  icon: Icons.confirmation_number_outlined,
                                  label: event.ticketInfo,
                                ),
                              _InfoPill(
                                icon: Icons.person_outline,
                                label: event.organizer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.description_outlined,
                    title: 'Descripción',
                    child: Text(
                      event.description,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    icon: Icons.contact_page_outlined,
                    title: 'Contacto',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _CopyPill(
                          icon: Icons.email_outlined,
                          label: event.contactEmail,
                          onCopy: () => _copyToClipboard(
                            context,
                            event.contactEmail,
                            message: 'Email copiado',
                          ),
                        ),
                        _CopyPill(
                          icon: Icons.phone_outlined,
                          label: event.contactPhone,
                          onCopy: () => _copyToClipboard(
                            context,
                            event.contactPhone,
                            message: 'Teléfono copiado',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    icon: Icons.queue_music_outlined,
                    title: 'Lineup',
                    child: event.lineup.isEmpty
                        ? const _EmptySection(
                            icon: Icons.music_off_outlined,
                            message: 'Aún no hay artistas confirmados.',
                          )
                        : _ChipWrap(values: event.lineup),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    icon: Icons.local_offer_outlined,
                    title: 'Etiquetas',
                    child: event.tags.isEmpty
                        ? const _EmptySection(
                            icon: Icons.sell_outlined,
                            message: 'Sin etiquetas asociadas.',
                          )
                        : _ChipWrap(values: event.tags),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    icon: Icons.build_outlined,
                    title: 'Recursos necesarios',
                    child: event.resources.isEmpty
                        ? const _EmptySection(
                            icon: Icons.handyman_outlined,
                            message: 'Sin recursos registrados.',
                          )
                        : _ChipWrap(values: event.resources),
                  ),
                  if (event.notes?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.sticky_note_2_outlined,
                      title: 'Notas',
                      child: Text(
                        event.notes!,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  EmptyStateCard(
                    icon: Icons.tips_and_updates_outlined,
                    title: 'Acciones rápidas',
                    subtitle: 'Comparte o copia la ficha del evento en texto.',
                    trailing: IconButton(
                      tooltip: 'Copiar formato',
                      onPressed: copyEventTemplate,
                      icon: const Icon(Icons.copy_all_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: showShareComingSoon,
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartir ficha'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: copyEventTemplate,
                      icon: const Icon(Icons.copy_all_outlined),
                      label: const Text('Copiar formato'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _copyToClipboard(
  BuildContext context,
  String value, {
  required String message,
}) async {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return;
  await Clipboard.setData(ClipboardData(text: trimmed));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: scheme.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.values});

  final Iterable<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .where((value) => value.trim().isNotEmpty)
          .map(
            (value) => Chip(
              label: Text(value),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: scheme.surfaceContainerHighest,
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.65),
              ),
              labelStyle: theme.textTheme.labelMedium,
            ),
          )
          .toList(),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trimmed = label.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              trimmed,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyPill extends StatelessWidget {
  const _CopyPill({
    required this.icon,
    required this.label,
    required this.onCopy,
  });

  final IconData icon;
  final String label;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trimmed = label.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Text(
                  trimmed,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget que muestra el banner del evento con opción de subir/cambiar imagen
class _EventBanner extends StatelessWidget {
  const _EventBanner({
    required this.imageUrl,
    required this.isUploading,
    required this.onUpload,
    required this.eventTitle,
  });

  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onUpload;
  final String eventTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: hasImage ? 4 : 0,
      child: Stack(
        children: [
          // Imagen de fondo o placeholder con gradiente
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: hasImage
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primaryContainer,
                        scheme.secondaryContainer,
                        scheme.tertiaryContainer,
                      ],
                    ),
            ),
            child: hasImage
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.errorContainer,
                              scheme.primaryContainer,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 64,
                            color: scheme.onErrorContainer.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  )
                : null,
          ),

          // Overlay con gradiente para mejor legibilidad
          if (hasImage)
            Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),

          // Contenido
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Título del evento con efecto glassmorphism
                  if (hasImage)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        eventTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  if (!hasImage)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: scheme.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dale un toque de exclusividad',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sube un banner personalizado para este evento',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Botón de subir/cambiar imagen
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: hasImage
                  ? Colors.white.withValues(alpha: 0.25)
                  : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              elevation: hasImage ? 0 : 2,
              child: InkWell(
                onTap: isUploading ? null : onUpload,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: hasImage
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        )
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUploading)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: hasImage ? Colors.white : scheme.primary,
                          ),
                        )
                      else
                        Icon(
                          hasImage ? Icons.edit_outlined : Icons.add_photo_alternate_outlined,
                          size: 20,
                          color: hasImage ? Colors.white : scheme.onPrimaryContainer,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isUploading
                            ? 'Subiendo...'
                            : (hasImage ? 'Cambiar' : 'Subir banner'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: hasImage ? Colors.white : scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
