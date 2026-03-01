import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/ui/shell/sidebar_cubit.dart';
import 'manager_menu_list.dart';

class ManagerSidebar extends StatelessWidget {
  const ManagerSidebar({super.key, this.isCollapsed = false});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header / Logo Area
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 8.0 : 24.0,
              vertical: 24.0,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed)
                  Text(
                    'UpSessions PRO',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                IconButton(
                  icon: Icon(isCollapsed ? Icons.menu : Icons.menu_open),
                  onPressed: () {
                    context.read<SidebarCubit>().toggle();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // Menu List
          Expanded(
            child: SingleChildScrollView(
              child: ManagerMenuList(isCollapsed: isCollapsed),
            ),
          ),
          // Footer Area (Profile / Settings mapped in menu)
        ],
      ),
    );
  }
}
