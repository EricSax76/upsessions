import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import 'package:upsessions/modules/musicians/data/musicians_repository.dart';

class MusicianOnboardingPage extends StatefulWidget {
  const MusicianOnboardingPage({super.key});

  @override
  State<MusicianOnboardingPage> createState() => _MusicianOnboardingPageState();
}

class _MusicianOnboardingPageState extends State<MusicianOnboardingPage> {
  final _basicInfoKey = GlobalKey<FormState>();
  final _experienceKey = GlobalKey<FormState>();
  final _extrasKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _instrumentController = TextEditingController();
  final _cityController = TextEditingController();
  final _stylesController = TextEditingController();
  final _yearsController = TextEditingController(text: '0');
  final _photoUrlController = TextEditingController();
  final _bioController = TextEditingController();

  int _currentStep = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _instrumentController.dispose();
    _cityController.dispose();
    _stylesController.dispose();
    _yearsController.dispose();
    _photoUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              const Text('No pudimos encontrar tu sesión.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Volver a iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }

    final steps = _buildSteps();
    final progress = (_currentStep + 1) / steps.length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cuéntanos sobre ti y tu pasión por la música'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: steps[_currentStep],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => setState(() => _currentStep -= 1),
                      child: const Text('Atrás'),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              if (_validateCurrentStep()) {
                                if (_currentStep == steps.length - 1) {
                                  _submit(user.id);
                                } else {
                                  setState(() => _currentStep += 1);
                                }
                              }
                            },
                      child: Text(
                        _currentStep == steps.length - 1
                            ? 'Finalizar'
                            : 'Continuar',
                      ),
                    ),
                  ),
                ],
              ),
              if (_isSaving) ...[
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSteps() {
    return [
      Form(
        key: _basicInfoKey,
        child: _StepCard(
          title: 'Tu identidad musical',
          description:
              'Comparte tu nombre artístico y el/los instrumento/S que tocas.',
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre artístico',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa tu nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instrumentController,
                decoration: const InputDecoration(
                  labelText: 'Instrumento principal',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Indica tu instrumento'
                    : null,
              ),
            ],
          ),
        ),
      ),
      Form(
        key: _experienceKey,
        child: _StepCard(
          title: 'Tu trayectoria musical',
          description:
              '¿Qué estilos te definen? Usa comas para separar varios estilos.',
          child: Column(
            children: [
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa tu ciudad'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stylesController,
                decoration: const InputDecoration(
                  labelText: 'Estilos (ej: Rock, Blues)',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Al menos un estilo'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Años de experiencia',
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      Form(
        key: _extrasKey,
        child: _StepCard(
          title: 'Tu sello personal',
          description:
              'Añade una foto o breve descripción para destacar en la comunidad.',
          child: Column(
            children: [
              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de tu foto (opcional)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Breve bio (opcional)',
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _basicInfoKey.currentState?.validate() ?? false;
      case 1:
        return _experienceKey.currentState?.validate() ?? false;
      case 2:
        return _extrasKey.currentState?.validate() ?? true;
      default:
        return true;
    }
  }

  Future<void> _submit(String musicianId) async {
    if (!(_extrasKey.currentState?.validate() ?? true)) {
      return;
    }
    setState(() => _isSaving = true);
    final repository = context.read<MusiciansRepository>();
    final styles = _stylesController.text
        .split(',')
        .map((style) => style.trim())
        .where((style) => style.isNotEmpty)
        .toList();
    final experience = int.tryParse(_yearsController.text) ?? 0;

    try {
      await repository.saveProfile(
        musicianId: musicianId,
        name: _nameController.text.trim(),
        instrument: _instrumentController.text.trim(),
        city: _cityController.text.trim(),
        styles: styles,
        experienceYears: experience,
        photoUrl: _photoUrlController.text.trim().isEmpty
            ? null
            : _photoUrlController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
      );
      if (!mounted) return;
      context.go(AppRoutes.userHome);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos guardar tu perfil: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(title),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
