import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/widgets/sm_avatar.dart';
import '../../cubits/my_studio_cubit.dart';
import '../../cubits/studios_state.dart';

class StudioSidebarHeader extends StatelessWidget {
  const StudioSidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return BlocBuilder<MyStudioCubit, StudiosState>(
      builder: (context, state) {
        final studio = state.myStudio;

        return Container(
          padding: const EdgeInsets.all(20),
          color: colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              SmAvatar(
                radius: 24,
                imageUrl: studio?.logoUrl,
                fallbackIcon: Icons.store,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studio?.name ?? loc.studioSidebarFallbackName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.studioSidebarSessionLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
