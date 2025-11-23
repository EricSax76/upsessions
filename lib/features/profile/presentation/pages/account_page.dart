import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../auth/application/auth_cubit.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _twoFactor = false;
  bool _newsletter = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Cuenta')),
        body: ListView(
          children: [
            SwitchListTile(
              value: _twoFactor,
              title: const Text('Autenticación de dos pasos'),
              onChanged: (value) => setState(() => _twoFactor = value),
            ),
            SwitchListTile(
              value: _newsletter,
              title: const Text('Recibir boletines'),
              onChanged: (value) => setState(() => _newsletter = value),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
