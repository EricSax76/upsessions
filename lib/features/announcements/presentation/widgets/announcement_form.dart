import 'package:flutter/material.dart';

import '../../domain/announcement_entity.dart';

class AnnouncementForm extends StatefulWidget {
  const AnnouncementForm({super.key, required this.onSubmit});

  final ValueChanged<AnnouncementEntity> onSubmit;

  @override
  State<AnnouncementForm> createState() => _AnnouncementFormState();
}

class _AnnouncementFormState extends State<AnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _instrumentController = TextEditingController();
  final _stylesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _instrumentController.dispose();
    _stylesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final styles = _stylesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final entity = AnnouncementEntity(
      id: '',
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      city: _cityController.text.trim(),
      author: '',
      authorId: '',
      province: _provinceController.text.trim(),
      instrument: _instrumentController.text.trim(),
      styles: styles,
      publishedAt: DateTime.now(),
    );
    widget.onSubmit(entity);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Título'),
            validator: (value) => value != null && value.isNotEmpty ? null : 'Campo obligatorio',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'Ciudad'),
            validator: (value) => value != null && value.isNotEmpty ? null : 'Campo obligatorio',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _provinceController,
            decoration: const InputDecoration(labelText: 'Provincia'),
            validator: (value) => value != null && value.isNotEmpty ? null : 'Campo obligatorio',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _instrumentController,
            decoration: const InputDecoration(labelText: 'Instrumento'),
            validator: (value) => value != null && value.isNotEmpty ? null : 'Campo obligatorio',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _stylesController,
            decoration: const InputDecoration(
              labelText: 'Estilos (separados por coma)',
              hintText: 'Ej: Rock, Pop',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bodyController,
            decoration: const InputDecoration(labelText: 'Descripción'),
            maxLines: 4,
            validator: (value) => value != null && value.length >= 10 ? null : 'Describe mejor tu anuncio',
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: _submit, child: const Text('Publicar anuncio')),
          ),
        ],
      ),
    );
  }
}
