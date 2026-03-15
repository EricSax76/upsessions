import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/constants/app_spacing.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/ui/shell/auth_shell.dart';
import 'package:upsessions/core/widgets/gap.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/event_manager/repositories/event_manager_repository.dart';
import 'package:upsessions/modules/venues/cubits/venue_register_cubit.dart';
import 'package:upsessions/modules/venues/cubits/venue_register_state.dart';
import 'package:upsessions/modules/venues/ui/forms/venue_register_validator.dart';

class VenueRegisterPage extends StatelessWidget {
  const VenueRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VenueRegisterCubit(
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<VenueRegisterCubit>().register();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VenueRegisterCubit, VenueRegisterState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<VenueRegisterCubit>().clearError();
        }
        if (state.status == VenueRegisterStatus.success) {
          context.go(AppRoutes.venuesDashboard);
        }
      },
      builder: (context, state) {
        final cubit = context.read<VenueRegisterCubit>();
        final draft = cubit.draft;
        final isSubmitting = state.status == VenueRegisterStatus.submitting;

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
                      controller: draft.venueNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del local o empresa',
                        hintText: 'Ej. Sala Horizonte',
                      ),
                      validator: (value) =>
                          VenueRegisterValidator.required(value),
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: draft.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'correo@ejemplo.com',
                      ),
                      validator: (value) => VenueRegisterValidator.email(value),
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: draft.passwordController,
                      obscureText: state.obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Mínimo 6 caracteres',
                        suffixIcon: IconButton(
                          onPressed: cubit.togglePasswordVisibility,
                          icon: Icon(
                            state.obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          VenueRegisterValidator.password(value),
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: draft.contactPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de contacto',
                        hintText: '+34 600 000 000',
                      ),
                      validator: (value) =>
                          VenueRegisterValidator.required(value),
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: draft.cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        hintText: 'Ej. Madrid',
                      ),
                      validator: (value) =>
                          VenueRegisterValidator.required(value),
                    ),
                    const VSpace(AppSpacing.md),
                    TextFormField(
                      controller: draft.websiteController,
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
