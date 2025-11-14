import 'package:flutter/material.dart';

import '../../data/profile_repository.dart';
import '../../domain/profile_entity.dart';
import '../widgets/profile_form.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final ProfileRepository _repository = ProfileRepository();
  ProfileEntity? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dto = await _repository.fetchProfile();
    setState(() => _profile = dto.toEntity());
  }

  void _save(ProfileEntity profile) {
    setState(() => _profile = profile);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ProfileForm(profile: profile, onSave: _save),
            ),
    );
  }
}
