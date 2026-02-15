import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/announcement_entity.dart';
import '../widgets/announcement_form/basic_info_section.dart';
import '../widgets/announcement_form/image_section.dart';
import '../widgets/announcement_form/location_instrument_section.dart';

class AnnouncementForm extends StatefulWidget {
  const AnnouncementForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  final void Function(AnnouncementEntity, XFile?) onSubmit;
  final bool isLoading;

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
  XFile? _pickedImage;

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
    if (widget.isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    final styles =
        _stylesController.text
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
    widget.onSubmit(entity, _pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          BasicInfoSection(
            titleController: _titleController,
            bodyController: _bodyController,
          ),
          const SizedBox(height: 16),
          LocationInstrumentSection(
            cityController: _cityController,
            provinceController: _provinceController,
            instrumentController: _instrumentController,
            stylesController: _stylesController,
          ),
          const SizedBox(height: 16),
          ImageSection(
            pickedImage: _pickedImage,
            onImagePicked: (image) => setState(() => _pickedImage = image),
            onImageRemoved: () => setState(() => _pickedImage = null),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: widget.isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              icon:
                  widget.isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check_circle_outline),
              label: Text(
                widget.isLoading ? 'Publicando...' : 'Publicar anuncio',
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
