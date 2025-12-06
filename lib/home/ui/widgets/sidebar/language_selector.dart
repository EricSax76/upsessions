import 'package:flutter/material.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _language = 'Español';

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _language,
      decoration: const InputDecoration(labelText: 'Idioma'),
      items: const [
        DropdownMenuItem(value: 'Español', child: Text('Español')),
        DropdownMenuItem(value: 'English', child: Text('English')),
      ],
      onChanged: (value) => setState(() => _language = value ?? _language),
    );
  }
}
