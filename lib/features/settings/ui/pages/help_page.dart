import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Centro de ayuda',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Preguntas frecuentes'),
                    leading: Icon(Icons.help_outline),
                  ),
                  ListTile(
                    title: Text('Contáctanos'),
                    leading: Icon(Icons.mail_outline),
                  ),
                  ListTile(
                    title: Text('Reportar problema'),
                    leading: Icon(Icons.warning_amber_outlined),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
