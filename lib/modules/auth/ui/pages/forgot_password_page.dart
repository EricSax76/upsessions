import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/validators.dart';
import '../../cubits/auth_cubit.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  static const double _maxWidth = 420;

  @override
  void initState() {
    super.initState();
    // The cubit should be responsible for clearing its state
    context.read<AuthCubit>().clearPasswordResetState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _reset() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().sendPasswordReset(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    // Localization constants
    const pageTitle = 'Recuperar contraseña';
    const instructionsText = 'Ingresa el correo con el que te registraste';
    const emailLabel = 'Correo';
    const sendButtonText = 'Enviar instrucciones';
    const successMessage = 'Te enviamos las instrucciones por correo.';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(pageTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isResetFlow =
                    state.lastAction == AuthAction.resetPassword;
                final isLoading = state.isLoading && isResetFlow;
                final success = state.passwordResetEmailSent && isResetFlow;
                final message = isResetFlow
                    ? (success ? successMessage : state.errorMessage)
                    : null;

                return Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(instructionsText),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: emailLabel),
                        validator: AppValidators.isValidEmail,
                      ),
                      const SizedBox(height: 16),
                      if (message != null)
                        Text(
                          message,
                          style: TextStyle(
                            color: success
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: isLoading ? null : _reset,
                        child: isLoading
                            ? SizedBox.square(
                                dimension: textTheme.bodyLarge?.fontSize,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(sendButtonText),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
