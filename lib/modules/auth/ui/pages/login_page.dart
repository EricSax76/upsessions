import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../cubits/auth_cubit.dart';
import '../widgets/auth_layout.dart';
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
          if (state.studioId != null) {
            context.go(AppRoutes.studiosDashboard);
          } else {
             context.go(AppRoutes.userHome);
          }
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final localizations = AppLocalizations.of(context);
          final isSubmitting =
              state.isLoading && state.lastAction == AuthAction.login;

          return Stack(
            children: [
              AuthLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: AppLogo(label: localizations.appBrandName),
                    ),
                    const VSpace(AppSpacing.xxl),
                    Text(
                      localizations.login,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const VSpace(AppSpacing.lg),
                    const LoginForm(),
                    const VSpace(AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => context.push(AppRoutes.forgotPassword),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: Colors.white70),
                          child: Text(localizations.forgotPassword),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.register),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            localizations.createAccount,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const VSpace(AppSpacing.section),
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(thickness: 1, color: Colors.white24)),
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
                            child: Divider(thickness: 1, color: Colors.white24)),
                      ],
                    ),
                    const VSpace(AppSpacing.section),
                    SocialLoginButtons(
                      onSelected: (provider) => _onSocialLogin(context, provider),
                    ),
                    const VSpace(AppSpacing.xl),
                    Center(
                      child: TextButton(
                        onPressed: () {
                           context.push(AppRoutes.studiosLogin);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.storefront, color: Colors.white70),
                            const SizedBox(width: 8),
                             RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                children: [
                                  const TextSpan(text: '¿Tienes una Sala de Ensayo? '),
                                  TextSpan(
                                    text: 'Ingresa aquí',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
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
