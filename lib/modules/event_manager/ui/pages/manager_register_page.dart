import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/constants/app_spacing.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/widgets/gap.dart';
import 'package:upsessions/core/ui/shell/auth_shell.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/event_manager/repositories/event_manager_repository.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_state.dart';

class ManagerRegisterPage extends StatelessWidget {
  const ManagerRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventManagerAuthCubit(
        authRepository: locate<AuthRepository>(),
        managerRepository: locate<EventManagerRepository>(),
      ),
      child: const _ManagerRegisterView(),
    );
  }
}

class _ManagerRegisterView extends StatefulWidget {
  const _ManagerRegisterView();

  @override
  State<_ManagerRegisterView> createState() => _ManagerRegisterViewState();
}

class _ManagerRegisterViewState extends State<_ManagerRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _cityController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _contactPhoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<EventManagerAuthCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      managerName: _nameController.text.trim(),
      contactEmail: _emailController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      city: _cityController.text.trim(),
      specialties: ['General'], // default specialty
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventManagerAuthCubit, EventManagerAuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.status == EventManagerAuthStatus.authenticated) {
          context.go(AppRoutes.eventManagerDashboard);
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == EventManagerAuthStatus.loading;

        return Stack(
          children: [
            AuthShell(
              showAppBar: true,
              title: 'Registro Event Manager',
              onBackPressed: () => context.pop(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crea tu cuenta de organizador y comienza a gestionar tus eventos.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const VSpace(AppSpacing.lg),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Productora o Manager',
                        hintText: 'Ej. Rock Productions',
                      ),
                      validator: (value) => 
                          (value == null || value.isEmpty) ? 'Requerido' : null,
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        hintText: 'correo@ejemplo.com',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        if (!value.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Mínimo 6 caracteres',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.length < 6) ? 'Mínimo 6 caracteres' : null,
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: _contactPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de Contacto',
                        hintText: '+34 600 000 000',
                      ),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Requerido' : null,
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad principal',
                        hintText: 'Ej. Madrid',
                      ),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Requerido' : null,
                    ),
                    const VSpace(AppSpacing.xl),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(isSubmitting ? 'Registrando...' : 'Crear Cuenta'),
                      ),
                    ),
                    const VSpace(AppSpacing.md),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.eventManagerLogin),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión aquí'),
                    ),
                  ],
                ),
              ),
            ),
            if (isSubmitting)
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.scrim,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}
