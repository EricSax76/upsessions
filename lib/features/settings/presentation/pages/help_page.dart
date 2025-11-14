import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centro de ayuda')),
      body: ListView(
        children: const [
          ListTile(title: Text('Preguntas frecuentes'), leading: Icon(Icons.help_outline)),
          ListTile(title: Text('Contáctanos'), leading: Icon(Icons.mail_outline)),
          ListTile(title: Text('Reportar problema'), leading: Icon(Icons.warning_amber_outlined)),
        ],
      ),
    );
  }
}
