import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_layout.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../cubits/auth_cubit.dart';
import '../widgets/login_form.dart';
import '../widgets/social_login_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _onSocialLogin(BuildContext context, String provider) {
    final message = AppLocalizations.of(context).socialLoginPlaceholder(provider);
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
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
        }

        if (state.status == AuthStatus.authenticated) {
          context.go(AppRoutes.userHome);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final localizations = AppLocalizations.of(context);
          final isSubmitting =
              state.isLoading && state.lastAction == AuthAction.login;

          return Scaffold(
            floatingActionButton: FloatingActionButton.small(
              onPressed: () => context.push(AppRoutes.help),
              child: const Icon(Icons.question_mark_rounded),
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppLayout.maxAuthFormWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const VSpace(AppSpacing.xs),
                            Align(
                              alignment: Alignment.center,
                              child: AppLogo(
                                label: localizations.appBrandName,
                              ),
                            ),
                            const VSpace(AppSpacing.xxl),
                            Text(
                              localizations.login,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const VSpace(AppSpacing.lg),
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
                                  ),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const VSpace(AppSpacing.section),
                            Row(
                              children: [
                                const Expanded(child: Divider(thickness: 1)),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                const Expanded(child: Divider(thickness: 1)),
                              ],
                            ),
                            const VSpace(AppSpacing.section),
                            SocialLoginButtons(
                              onSelected: (provider) =>
                                  _onSocialLogin(context, provider),
                            ),
                            const VSpace(AppSpacing.sm),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Center(
                        child: LoadingIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
