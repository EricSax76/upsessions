import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../data/events_repository.dart';
import '../../domain/event_entity.dart';
import '../../../auth/data/auth_repository.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventsRepository _repository = locate();
  final AuthRepository _authRepository = locate();
  List<EventEntity> _events = const [];
  bool _loading = true;
  EventEntity? _preview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final events = await _repository.fetchUpcoming();
    if (!mounted) return;
    setState(() {
      _events = events;
      _preview = events.isNotEmpty ? events.first : null;
      _loading = false;
    });
  }

  Future<void> _handleDraft(EventEntity event) async {
    final saved = await _repository.saveDraft(event);
    if (!mounted) {
      return;
    }
    setState(() {
      _events = [
        saved,
        ..._events.where((existing) => existing.id != saved.id),
      ];
      _preview = saved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ficha de evento lista para compartir.')),
    );
  }

  void _viewEventDetail(EventEntity event) {
    if (!mounted) return;
    context.push(AppRoutes.eventDetail, extra: event);
  }

  void _handlePreviewSelection(EventEntity event) {
    setState(() => _preview = event);
  }

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      child: _EventsDashboard(
        events: _events,
        preview: _preview,
        loading: _loading,
        onRefresh: _load,
        onGenerateDraft: _handleDraft,
        onSelectForPreview: _handlePreviewSelection,
        onViewDetails: _viewEventDetail,
        ownerId: _authRepository.currentUser?.id,
      ),
    );
  }
}

class _EventsDashboard extends StatelessWidget {
  const _EventsDashboard({
    required this.events,
    required this.preview,
    required this.loading,
    required this.onRefresh,
    required this.onGenerateDraft,
    required this.onSelectForPreview,
    required this.onViewDetails,
    required this.ownerId,
  });

  final List<EventEntity> events;
  final EventEntity? preview;
  final bool loading;
  final Future<void> Function() onRefresh;
  final ValueChanged<EventEntity> onGenerateDraft;
  final ValueChanged<EventEntity> onSelectForPreview;
  final ValueChanged<EventEntity> onViewDetails;
  final String? ownerId;

  @override
  Widget build(BuildContext context) {
    final content = events.isEmpty && loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _EventsHeader(events: events),
                const SizedBox(height: 24),
                if (events.isNotEmpty)
                  _EventHighlightCard(
                    event: events.first,
                    onSelect: onSelectForPreview,
                    onViewDetails: onViewDetails,
                  ),
                if (events.isNotEmpty) const SizedBox(height: 32),
                if (events.isNotEmpty)
                  _EventList(
                    events: events.skip(1).toList(),
                    onSelect: onSelectForPreview,
                    onViewDetails: onViewDetails,
                  ),
                if (events.isNotEmpty) const SizedBox(height: 32),
                _EventPlannerSection(
                  preview: preview,
                  onGenerateDraft: onGenerateDraft,
                  ownerId: ownerId,
                ),
              ],
            ),
          );

    return SafeArea(
      child: Stack(
        children: [
          content,
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AnimatedOpacity(
              opacity: loading ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: loading
                  ? const LinearProgressIndicator(minHeight: 3)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsHeader extends StatelessWidget {
  const _EventsHeader({required this.events});

  final List<EventEntity> events;

  @override
  Widget build(BuildContext context) {
    final totalCapacity = events.fold<int>(
      0,
      (sum, event) => sum + event.capacity,
    );
    final weekLimit = DateTime.now().add(const Duration(days: 7));
    final thisWeek = events
        .where((event) => event.start.isBefore(weekLimit))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eventos y showcases',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Planifica tus sesiones. Genera una ficha en formato texto para compartirla por correo o chat.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _SummaryChip(
              label: 'Eventos activos',
              value: events.length.toString(),
              icon: Icons.event_available,
            ),
            _SummaryChip(
              label: 'Esta semana',
              value: thisWeek.toString(),
              icon: Icons.calendar_month,
            ),
            _SummaryChip(
              label: 'Capacidad total',
              value: '$totalCapacity personas',
              icon: Icons.people_alt_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventHighlightCard extends StatelessWidget {
  const _EventHighlightCard({
    required this.event,
    required this.onSelect,
    required this.onViewDetails,
  });

  final EventEntity event;
  final ValueChanged<EventEntity> onSelect;
  final ValueChanged<EventEntity> onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    final startTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start));
    final endTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.end));

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${loc.formatFullDate(event.start)} · $startTime - $endTime',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              '${event.venue} · ${event.city}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(event.description),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => onSelect(event),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Ver ficha en texto'),
                ),
                TextButton.icon(
                  onPressed: () => onSelect(event),
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copiar formato'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onViewDetails(event),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ver detalles'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({
    required this.events,
    required this.onSelect,
    required this.onViewDetails,
  });

  final List<EventEntity> events;
  final ValueChanged<EventEntity> onSelect;
  final ValueChanged<EventEntity> onViewDetails;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Otros eventos programados',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            for (final event in events) ...[
              _EventCard(
                event: event,
                onSelect: onSelect,
                onViewDetails: onViewDetails,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onSelect,
    required this.onViewDetails,
  });

  final EventEntity event;
  final ValueChanged<EventEntity> onSelect;
  final ValueChanged<EventEntity> onViewDetails;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final duration =
        '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start))} · ${event.venue}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(Icons.event, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${loc.formatMediumDate(event.start)} · $duration'),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copiar ficha',
                  onPressed: () => onSelect(event),
                  icon: const Icon(Icons.description),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.group_outlined,
                  label: '${event.capacity} personas',
                ),
                _InfoChip(
                  icon: Icons.local_offer_outlined,
                  label: event.ticketInfo,
                ),
                _InfoChip(icon: Icons.call_outlined, label: event.contactPhone),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onViewDetails(event),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ver detalles'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class _EventPlannerSection extends StatelessWidget {
  const _EventPlannerSection({
    required this.preview,
    required this.onGenerateDraft,
    required this.ownerId,
  });

  final EventEntity? preview;
  final ValueChanged<EventEntity> onGenerateDraft;
  final String? ownerId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crea una ficha utilitaria',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Completa los campos clave y obtén un texto que puedes pegar en un archivo plano o enviar por WhatsApp/Email.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _EventFormCard(
                      onGenerateDraft: onGenerateDraft,
                      ownerId: ownerId,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: _EventTextTemplateCard(event: preview)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EventFormCard(
                  onGenerateDraft: onGenerateDraft,
                  ownerId: ownerId,
                ),
                const SizedBox(height: 24),
                _EventTextTemplateCard(event: preview),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EventFormCard extends StatefulWidget {
  const _EventFormCard({required this.onGenerateDraft, required this.ownerId});

  final ValueChanged<EventEntity> onGenerateDraft;
  final String? ownerId;

  @override
  State<_EventFormCard> createState() => _EventFormCardState();
}

class _EventFormCardState extends State<_EventFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: '');
  final _cityController = TextEditingController(text: '');
  final _venueController = TextEditingController(text: '');
  final _descriptionController = TextEditingController(text: '');
  final _organizerController = TextEditingController(text: '');
  final _contactEmailController = TextEditingController(text: '');
  final _contactPhoneController = TextEditingController(text: '');
  final _lineupController = TextEditingController(text: '');
  final _tagsController = TextEditingController(text: '');
  final _ticketController = TextEditingController(text: '');
  final _capacityController = TextEditingController(text: '');
  final _resourcesController = TextEditingController(text: '');
  final _notesController = TextEditingController(text: '');

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _lineupController.dispose();
    _tagsController.dispose();
    _ticketController.dispose();
    _capacityController.dispose();
    _resourcesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start
          ? (_startTime ?? const TimeOfDay(hour: 19, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 22, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final ownerId = widget.ownerId;
    if (ownerId == null || ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes iniciar sesión como músico para crear un evento.',
          ),
        ),
      );
      return;
    }
    final date = _selectedDate ?? DateTime.now().add(const Duration(days: 5));
    final startTime = _startTime ?? const TimeOfDay(hour: 19, minute: 0);
    final endTime = _endTime ?? const TimeOfDay(hour: 22, minute: 0);
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    final event = EventEntity(
      id: '',
      ownerId: ownerId,
      title: _titleController.text.trim(),
      city: _cityController.text.trim(),
      venue: _venueController.text.trim(),
      start: startDateTime,
      end: endDateTime,
      description: _descriptionController.text.trim(),
      organizer: _organizerController.text.trim(),
      contactEmail: _contactEmailController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      lineup: _splitValues(_lineupController.text),
      tags: _splitValues(_tagsController.text),
      ticketInfo: _ticketController.text.trim(),
      capacity: capacity,
      resources: _splitValues(_resourcesController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    widget.onGenerateDraft(event);
  }

  List<String> _splitValues(String input) {
    return input
        .split(RegExp(r'[,\n]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final dateLabel = _selectedDate == null
        ? 'Selecciona una fecha'
        : loc.formatMediumDate(_selectedDate!);
    final startLabel = _startTime == null
        ? 'Inicio'
        : loc.formatTimeOfDay(_startTime!);
    final endLabel = _endTime == null ? 'Fin' : loc.formatTimeOfDay(_endTime!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del evento',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value != null && value.trim().isNotEmpty
                    ? null
                    : 'Campo obligatorio',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                      validator: (value) =>
                          value != null && value.trim().isNotEmpty
                          ? null
                          : 'Campo obligatorio',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(
                        labelText: 'Lugar / venue',
                      ),
                      validator: (value) =>
                          value != null && value.trim().isNotEmpty
                          ? null
                          : 'Campo obligatorio',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PickerField(
                      label: 'Fecha',
                      value: dateLabel,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _PickerField(
                            label: 'Inicio',
                            value: startLabel,
                            onTap: () => _pickTime(start: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PickerField(
                            label: 'Fin',
                            value: endLabel,
                            onTap: () => _pickTime(start: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                minLines: 3,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lineupController,
                decoration: const InputDecoration(
                  labelText: 'Lineup o dinámica (separado por coma)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _resourcesController,
                decoration: const InputDecoration(
                  labelText: 'Recursos/Backline (separado por coma)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ticketController,
                decoration: const InputDecoration(
                  labelText: 'Entradas o aporte',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacidad'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _organizerController,
                decoration: const InputDecoration(labelText: 'Organiza'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email de contacto',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (separados por coma)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales (opcional)',
                ),
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Generar ficha'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value),
      ),
    );
  }
}

class _EventTextTemplateCard extends StatelessWidget {
  const _EventTextTemplateCard({required this.event});

  final EventEntity? event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final template = event == null
        ? 'Aún no seleccionaste un evento.\nGenera uno con el formulario o toca un evento existente para ver su ficha.'
        : _buildTemplate(context, event!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Formato tipo archivo de texto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                template,
                style: const TextStyle(fontFamily: 'monospace', height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: event == null
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: template));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ficha copiada al portapapeles'),
                          ),
                        );
                      },
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copiar texto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildTemplate(BuildContext context, EventEntity event) {
    final loc = MaterialLocalizations.of(context);
    final buffer = StringBuffer()
      ..writeln('EVENTO: ${event.title}')
      ..writeln('FECHA: ${loc.formatFullDate(event.start)}')
      ..writeln(
        'HORARIO: ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start), alwaysUse24HourFormat: true)} - '
        '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.end), alwaysUse24HourFormat: true)}',
      )
      ..writeln('LUGAR: ${event.venue} (${event.city})')
      ..writeln('ORGANIZA: ${event.organizer}')
      ..writeln('LINEUP: ${event.lineup.join(' / ')}')
      ..writeln('CAPACIDAD: ${event.capacity} personas')
      ..writeln('RECURSOS: ${event.resources.join(', ')}')
      ..writeln('ENTRADAS: ${event.ticketInfo}')
      ..writeln('CONTACTO: ${event.contactEmail} | ${event.contactPhone}')
      ..writeln('DESCRIPCIÓN:\n${event.description}');
    if (event.notes?.isNotEmpty == true) {
      buffer
        ..writeln()
        ..writeln('NOTAS:\n${event.notes}');
    }
    buffer
      ..writeln()
      ..writeln('TAGS: ${event.tags.join(', ')}');
    return buffer.toString();
  }
}
