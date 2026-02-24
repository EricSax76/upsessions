import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/ui/shell/auth_shell.dart';
import '../../cubits/auth_cubit.dart';
import '../widgets/login_form.dart';
import '../widgets/social_login_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
          context.go(AppRoutes.splash);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final localizations = AppLocalizations.of(context);
          final isSubmitting =
              state.isLoading && state.lastAction == AuthAction.login;

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
                      localizations.login,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const VSpace(AppSpacing.md),
                    const LoginForm(),
                    const VSpace(AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.forgotPassword),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          child: Text(localizations.forgotPassword),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.register),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            localizations.createAccount,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const VSpace(AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            localizations.loginContinueWith,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const VSpace(AppSpacing.sm),
                    SocialLoginButtons(
                      onSelected: (provider) =>
                          _onSocialLogin(context, provider),
                    ),
                    const VSpace(AppSpacing.md),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.push(AppRoutes.studiosLogin);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '¿Tienes una Sala de Ensayo?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ingresa aquí',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: Theme.of(context).colorScheme.scrim,
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
