import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../../auth/ui/widgets/auth_layout.dart';
import '../../../auth/ui/widgets/login_form.dart';

class StudioLoginPage extends StatelessWidget {
  const StudioLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.lastAction == AuthAction.login) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        if (state.status == AuthStatus.authenticated) {
          // Redirect to Studio Dashboard instead of UserHome
          context.go(AppRoutes.studiosDashboard);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isSubmitting =
              state.isLoading && state.lastAction == AuthAction.login;

          return Stack(
            children: [
              AuthLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Icon(
                        Icons.storefront,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const VSpace(AppSpacing.lg),
                    Text(
                      'Acceso para Estudios',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const VSpace(AppSpacing.sm),
                    Text(
                      'Gestiona tus salas y reservas',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const VSpace(AppSpacing.xl),
                    const LoginForm(), // Reuse existing login form
                    const VSpace(AppSpacing.md),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.studiosRegister),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('¿No tienes cuenta? Regístrate gratis'),
                      // Ideally we'd pass a param to register to know to redirect back here or to studio creation,
                      // but for now standard register flow -> Home -> Sidebar -> Manage Studio works as a fallback,
                      // OR we assume they come back here to login.
                    ),
                  ],
                ),
              ),
              if (isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: const Center(child: LoadingIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
