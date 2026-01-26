import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_layout.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/constants/breakpoints.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
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
          context.go(AppRoutes.userHome);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final localizations = AppLocalizations.of(context);
          final isSubmitting =
              state.isLoading && state.lastAction == AuthAction.login;
          final isWebDesktop = kIsWeb && context.isDesktop;

          final formContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: ThemeToggleButton(),
              ),
              const VSpace(AppSpacing.xs),
              Align(
                alignment: Alignment.center,
                child: AppLogo(label: localizations.appBrandName),
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
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(localizations.forgotPassword),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      localizations.createAccount,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const VSpace(AppSpacing.section),
              SocialLoginButtons(
                onSelected: (provider) => _onSocialLogin(context, provider),
              ),
              const VSpace(AppSpacing.sm),
            ],
          );

          final scrollableForm = SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: isWebDesktop
                ? formContent
                : ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxAuthFormWidth,
                    ),
                    child: formContent,
                  ),
          );

          return Scaffold(
            floatingActionButton: FloatingActionButton.small(
              onPressed: () => context.push(AppRoutes.help),
              child: const Icon(Icons.question_mark_rounded),
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (isWebDesktop)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox.expand(
                          child: Image.asset(
                            'assets/images/logos/upsessions_foto_login.png',
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SafeArea(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: scrollableForm,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SafeArea(child: Center(child: scrollableForm)),
                if (isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Theme.of(context).colorScheme.scrim,
                      child: const Center(child: LoadingIndicator()),
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
