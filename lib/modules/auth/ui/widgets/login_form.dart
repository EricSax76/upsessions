import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gap.dart';

import '../../cubits/auth_cubit.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signIn(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading =
            state.isLoading && state.lastAction == AuthAction.login;
        final error = state.lastAction == AuthAction.login
            ? state.errorMessage
            : null;
        final localization = AppLocalizations.of(context);
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                decoration: InputDecoration(
                  hintText: localization.emailHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.emailRequired;
                  }
                  if (!value.contains('@')) {
                    return localization.emailInvalid;
                  }
                  return null;
                },
              ),
              const VSpace(AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  hintText: localization.passwordHint,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    tooltip: _obscurePassword
                        ? localization.passwordToggleShow
                        : localization.passwordToggleHide,
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) => value != null && value.length >= 4
                    ? null
                    : localization.passwordTooShort,
              ),
              const VSpace(AppSpacing.md),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(localization.login),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
