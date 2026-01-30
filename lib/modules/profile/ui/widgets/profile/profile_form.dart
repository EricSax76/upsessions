import 'package:flutter/material.dart';

import 'package:upsessions/modules/auth/models/profile_entity.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, required this.profile, required this.onSave});

  final ProfileEntity profile;
  final ValueChanged<ProfileEntity> onSave;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.profile.bio);
    _locationController = TextEditingController(text: widget.profile.location);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(
      widget.profile.copyWith(
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _bioController,
          decoration: const InputDecoration(labelText: 'Biografía'),
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: 'Ubicación'),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _save,
            child: const Text('Guardar cambios'),
          ),
        ),
      ],
    );
  }
}
