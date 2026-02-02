import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/cubit/locale_cubit.dart';

import 'package:upsessions/core/widgets/settings_tile.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.select((LocaleCubit cubit) => cubit.state);
    final theme = Theme.of(context);

    return SettingsTile(
      onTap: () => _showLanguageMenu(context, currentLocale),
      icon: Icons.language,
      title: _getLanguageName(currentLocale.languageCode),
      trailing: Icon(
        Icons.arrow_drop_down,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _showLanguageMenu(BuildContext context, Locale currentLocale) async {
    final cubit = context.read<LocaleCubit>();
    final selected = await showMenu<Locale>(
      context: context,
      position: const RelativeRect.fromLTRB(
        0,
        0,
        0,
        0,
      ), // Adjust as needed or use a Dialog
      items: AppLocalizations.supportedLocales.map((locale) {
        return PopupMenuItem<Locale>(
          value: locale,
          child: Text(_getLanguageName(locale.languageCode)),
        );
      }).toList(),
    );

    if (selected != null && selected != currentLocale) {
      cubit.changeLocale(selected);
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return code.toUpperCase();
    }
  }
}
