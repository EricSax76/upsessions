import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/ui/shell/sidebar_cubit.dart';
import 'venue_menu_list.dart';

class VenueSidebar extends StatelessWidget {
  const VenueSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return BlocBuilder<SidebarCubit, bool>(
      builder: (context, isCollapsed) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 8 : 24,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isCollapsed)
                      Expanded(
                        child: Text(
                          localizations.venueShellBrandName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    IconButton(
                      icon: Icon(isCollapsed ? Icons.menu : Icons.menu_open),
                      onPressed: () => context.read<SidebarCubit>().toggle(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: VenueMenuList(isCollapsed: isCollapsed),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
