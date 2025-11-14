import 'package:flutter/material.dart';

import '../../data/auth_repository.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthRepository _repository = AuthRepository();
  bool _sending = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _message = null;
    });
    try {
      await _repository.sendPasswordReset(_emailController.text.trim());
      setState(() => _message = 'Te enviamos las instrucciones por correo.');
    } catch (error) {
      setState(() => _message = error.toString());
    } finally {
      setState(() => _sending = false);
    }
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ingresa el correo con el que te registraste'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (value) => value != null && value.contains('@') ? null : 'Correo inválido',
                  ),
                  const SizedBox(height: 16),
                  if (_message != null)
                    Text(
                      _message!,
                      style: TextStyle(color: _message!.contains('instrucciones') ? Colors.green : Colors.redAccent),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _sending ? null : _reset,
                    child: _sending ? const CircularProgressIndicator() : const Text('Enviar instrucciones'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
