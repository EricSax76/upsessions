import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/locale_cubit.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.select((LocaleCubit cubit) => cubit.state);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          // ignore: deprecated_member_use
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLanguageMenu(context, currentLocale),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.language, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getLanguageName(currentLocale.languageCode),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
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
