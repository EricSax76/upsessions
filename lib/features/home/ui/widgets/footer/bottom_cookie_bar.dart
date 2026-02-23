import 'package:flutter/material.dart';

class BottomCookieBar extends StatefulWidget {
  const BottomCookieBar({super.key});

  @override
  State<BottomCookieBar> createState() => _BottomCookieBarState();
}

class _BottomCookieBarState extends State<BottomCookieBar> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    if (_accepted) {
      return const SizedBox.shrink();
    }
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Text('Usamos cookies para mejorar tu experiencia en la comunidad musical.'),
            ),
            TextButton(
              onPressed: () => setState(() => _accepted = true),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }
}
