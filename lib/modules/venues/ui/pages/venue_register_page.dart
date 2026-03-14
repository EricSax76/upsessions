import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/constants/app_spacing.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/ui/shell/auth_shell.dart';
import 'package:upsessions/core/widgets/gap.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_state.dart';
import 'package:upsessions/modules/event_manager/repositories/event_manager_repository.dart';

class VenueRegisterPage extends StatelessWidget {
  const VenueRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventManagerAuthCubit(
        authRepository: locate<AuthRepository>(),
        managerRepository: locate<EventManagerRepository>(),
      ),
      child: const _VenueRegisterView(),
    );
  }
}

class _VenueRegisterView extends StatefulWidget {
  const _VenueRegisterView();

  @override
  State<_VenueRegisterView> createState() => _VenueRegisterViewState();
}

class _VenueRegisterViewState extends State<_VenueRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _venueNameController.dispose();
    _contactPhoneController.dispose();
    _cityController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<EventManagerAuthCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      managerName: _venueNameController.text.trim(),
      contactEmail: _emailController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      city: _cityController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      specialties: const ['venues'],
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
          context.go(AppRoutes.venuesDashboard);
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == EventManagerAuthStatus.loading;

        return Stack(
          children: [
            AuthShell(
              showAppBar: true,
              title: 'Registro Venues',
              onBackPressed: () => context.pop(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crea tu cuenta para gestionar locales y disponibilidad.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const VSpace(AppSpacing.lg),
                    TextFormField(
                      controller: _venueNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del local o empresa',
                        hintText: 'Ej. Sala Horizonte',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'correo@ejemplo.com',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requerido';
                        }
                        if (!value.contains('@')) {
                          return 'Correo inválido';
                        }
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
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: _contactPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de contacto',
                        hintText: '+34 600 000 000',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        hintText: 'Ej. Madrid',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: _websiteController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Web (opcional)',
                        hintText: 'https://...',
                      ),
                    ),
                    const VSpace(AppSpacing.xl),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          isSubmitting ? 'Registrando...' : 'Crear cuenta',
                        ),
                      ),
                    ),
                    const VSpace(AppSpacing.md),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.venuesAuthLogin),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
