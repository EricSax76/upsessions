import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';

import '../../../auth/cubits/auth_cubit.dart';

import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../repositories/studios_repository.dart';
import '../../services/studio_image_service.dart';
import '../../models/studio_entity.dart';

class StudioRegisterPage extends StatefulWidget {
  const StudioRegisterPage({super.key});

  @override
  State<StudioRegisterPage> createState() => _StudioRegisterPageState();
}

class _StudioRegisterPageState extends State<StudioRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Auth Fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Studio Fields
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController(); // Razón Social
  final _cifController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  int _currentStep = 0;
  bool _registrationInProgress = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StudiosCubit(
            repository: locate<StudiosRepository>(),
            imageService: locate<StudioImageService>(),
          ),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, authState) {
          if (authState.status == AuthStatus.authenticated &&
              _registrationInProgress) {
            // User registered successfully, now create studio
            _createStudio(context, authState.user!.id);
          }
          if (authState.errorMessage != null && _registrationInProgress) {
            setState(() => _registrationInProgress = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(authState.errorMessage!)));
          }
        },
        child: BlocListener<StudiosCubit, StudiosState>(
          listener: (context, studioState) {
            if (studioState.status == StudiosStatus.success &&
                _registrationInProgress) {
              // Studio created, navigate to dashboard
              context.go(AppRoutes.studiosDashboard);
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Registro de Estudio')),
            body: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0) {
                  // Validate Step 1 (Auth)
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() => _currentStep = 1);
                  }
                } else {
                  // Validate Step 2 (Studio) & Submit
                  if (_formKey.currentState?.validate() ?? false) {
                    _submitRegistration();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep = 0);
                } else {
                  context.pop();
                }
              },
              steps: [
                Step(
                  title: const Text('Cuenta de Usuario'),
                  content: Form(
                    key: _currentStep == 0 ? _formKey : null,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Correo Electrónico',
                          ),
                          validator: (v) => v?.contains('@') == true
                              ? null
                              : 'Email inválido',
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                          ),
                          obscureText: true,
                          validator: (v) => (v?.length ?? 0) >= 6
                              ? null
                              : 'Mínimo 6 caracteres',
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar Contraseña',
                          ),
                          obscureText: true,
                          validator: (v) => v == _passwordController.text
                              ? null
                              : 'Las contraseñas no coinciden',
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.editing,
                ),
                Step(
                  title: const Text('Datos del Estudio'),
                  content: Form(
                    key: _currentStep == 1 ? _formKey : null,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre Comercial',
                          ),
                          validator: (v) =>
                              v?.isNotEmpty == true ? null : 'Requerido',
                        ),
                        TextFormField(
                          controller: _businessNameController,
                          decoration: const InputDecoration(
                            labelText: 'Razón Social',
                          ),
                          validator: (v) =>
                              v?.isNotEmpty == true ? null : 'Requerido',
                        ),
                        TextFormField(
                          controller: _cifController,
                          decoration: const InputDecoration(labelText: 'CIF'),
                          validator: (v) =>
                              v?.isNotEmpty == true ? null : 'Requerido',
                        ),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Dirección',
                          ),
                          validator: (v) =>
                              v?.isNotEmpty == true ? null : 'Requerido',
                        ),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                          ),
                          validator: (v) =>
                              v?.isNotEmpty == true ? null : 'Requerido',
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep == 1
                      ? StepState.editing
                      : StepState.indexed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitRegistration() {
    setState(() => _registrationInProgress = true);
    // 1. Create Auth User
    context.read<AuthCubit>().register(
      email: _emailController.text,
      password: _passwordController.text,
      displayName: _nameController
          .text, // Use studio name as user display name initially
    );
  }

  void _createStudio(BuildContext context, String userId) {
    final studio = StudioEntity(
      id: const Uuid().v4(),
      ownerId: userId,
      name: _nameController.text,
      businessName: _businessNameController.text,
      cif: _cifController.text,
      description: _descriptionController.text,
      address: _addressController.text,
      contactEmail: _emailController.text,
      contactPhone: _phoneController.text,
    );
    context.read<StudiosCubit>().createStudio(studio);
  }
}
