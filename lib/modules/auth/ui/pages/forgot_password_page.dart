import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth_cubit.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().clearMessages();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isResetFlow =
                    state.lastAction == AuthAction.resetPassword;
                final isLoading = state.isLoading && isResetFlow;
                final success = state.passwordResetEmailSent && isResetFlow;
                final message = isResetFlow
                    ? (success
                          ? 'Te enviamos las instrucciones por correo.'
                          : state.errorMessage)
                    : null;
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Ingresa el correo con el que te registraste'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Correo'),
                        validator: (value) =>
                            value != null && value.contains('@')
                            ? null
                            : 'Correo inválido',
                      ),
                      const SizedBox(height: 16),
                      if (message != null)
                        Text(
                          message,
                          style: TextStyle(
                            color: success ? Colors.green : Colors.redAccent,
                          ),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: isLoading ? null : _reset,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Enviar instrucciones'),
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
