import 'package:flutter/material.dart';

class MusicianSearchTopBar extends StatelessWidget {
  const MusicianSearchTopBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onPressed,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Busca por nombre, estilo o instrumento',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Buscar'),
            ),
          ],
        ),
      ),
    );
  }
}
