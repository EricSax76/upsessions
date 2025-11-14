import 'package:flutter/material.dart';

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
    return Scaffold(
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
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
