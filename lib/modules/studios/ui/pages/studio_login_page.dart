import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/shell/auth_shell.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../../auth/ui/widgets/login_form.dart';
import '../../../auth/ui/widgets/social_login_buttons.dart';

class StudioLoginPage extends StatelessWidget {
  const StudioLoginPage({super.key});

  void _onSocialLogin(BuildContext context, String provider) {
    final message = AppLocalizations.of(
      context,
    ).socialLoginPlaceholder(provider);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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
          final localizations = AppLocalizations.of(context);

          return Stack(
            children: [
              AuthShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: AppLogo(label: localizations.appBrandName),
                    ),
                    const VSpace(AppSpacing.lg),
                    Text(
                      'Acceso para Estudios',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    const VSpace(AppSpacing.lg),
                    const LoginForm(), // Reuse existing login form
                    const VSpace(AppSpacing.sm),
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
                    const VSpace(AppSpacing.sm),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(thickness: 1, color: Colors.white24),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            localizations.loginContinueWith,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(thickness: 1, color: Colors.white24),
                        ),
                      ],
                    ),
                    const VSpace(AppSpacing.sm),
                    SocialLoginButtons(
                      onSelected: (provider) => _onSocialLogin(context, provider),
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
