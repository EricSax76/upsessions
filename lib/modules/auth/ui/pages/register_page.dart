import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../cubits/auth_cubit.dart';
import '../widgets/auth_layout.dart';
import '../widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(AppRoutes.userHome);
        }
        if (state.errorMessage != null &&
            state.lastAction == AuthAction.register) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
              ),
            );
        }
      },
      builder: (context, state) {
        final isSubmitting =
            state.isLoading && state.lastAction == AuthAction.register;
        
        return Stack(
          children: [
             AuthLayout(
              showAppBar: true,
              title: l10n.createAccount,
              onBackPressed: () => context.pop(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                   // TODO: Localize strings
                  Text(
                    'Únete a la red de Solo Músicos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                       color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const RegisterForm(),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.pop(),
                    // TODO: Localize strings
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
             if (isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
          ],
        );
      },
    );
  }
}
