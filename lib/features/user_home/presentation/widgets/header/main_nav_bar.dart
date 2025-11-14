import 'package:flutter/material.dart';

class MainNavBar extends StatefulWidget {
  const MainNavBar({super.key});

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  final List<String> _sections = ['Inicio', 'Músicos', 'Anuncios', 'Mensajes', 'Perfil'];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (int i = 0; i < _sections.length; i++)
          ChoiceChip(
            label: Text(_sections[i]),
            selected: _selectedIndex == i,
            onSelected: (_) => setState(() => _selectedIndex = i),
          ),
      ],
    );
  }
}
