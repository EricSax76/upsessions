import 'package:flutter/material.dart';

class MusicianFilterPanel extends StatelessWidget {
  const MusicianFilterPanel({super.key, required this.controller, required this.onSearch});

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar músicos o estilos',
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(onPressed: onSearch, icon: const Icon(Icons.tune), label: const Text('Filtrar')),
      ],
    );
  }
}
