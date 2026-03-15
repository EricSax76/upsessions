import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/ui/shell/sidebar_cubit.dart';
import 'package:upsessions/features/home/ui/widgets/sidebar/user_sidebar.dart';
import 'package:upsessions/modules/event_manager/ui/widgets/shell/manager_sidebar.dart';

class CoreShell extends StatelessWidget {
  const CoreShell({
    super.key,
    required this.child,
    this.sidebar,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation = FloatingActionButtonLocation.endFloat,
    this.mobileBreakpoint = 700,
    this.desktopBreakpoint = 1200,
  });

  final Widget child;

  final Widget? sidebar;

  final PreferredSizeWidget? appBar;

  final Widget? bottomNavigationBar;

  final Widget? floatingActionButton;

  final FloatingActionButtonLocation floatingActionButtonLocation;

  final double mobileBreakpoint;

  final double desktopBreakpoint;

  static const Duration _webSidebarExpandDuration = Duration(milliseconds: 160);
  static const Duration _webSidebarCollapseDuration = Duration(
    milliseconds: 120,
  );
  static const Duration _defaultSidebarDuration = Duration(milliseconds: 220);

  Duration _sidebarDuration(bool isCollapsed) {
    if (!kIsWeb) return _defaultSidebarDuration;
    return isCollapsed
        ? _webSidebarCollapseDuration
        : _webSidebarExpandDuration;
  }

  Curve _sidebarCurve(bool isCollapsed) {
    if (!kIsWeb) return Curves.easeInOutCubic;
    return isCollapsed ? Curves.easeInCubic : Curves.easeOutCubic;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final isWideLayout = kIsWeb
        ? width >= mobileBreakpoint
        : width >= desktopBreakpoint;

    return Scaffold(
      drawer: (!isWideLayout && sidebar != null)
          ? Drawer(child: SafeArea(child: sidebar!))
          : null,

      appBar: appBar,

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permanent Sidebar on wide layout
          if (isWideLayout && sidebar != null) ...[
            BlocBuilder<SidebarCubit, bool>(
              builder: (context, isCollapsed) {
                // If sidebar is UserSidebar, inject isCollapsed
                Widget sidebarWidget = sidebar!;
                if (sidebarWidget is UserSidebar) {
                  sidebarWidget = UserSidebar(isCollapsed: isCollapsed);
                } else if (sidebarWidget is ManagerSidebar) {
                  sidebarWidget = ManagerSidebar(isCollapsed: isCollapsed);
                }

                return AnimatedContainer(
                  duration: _sidebarDuration(isCollapsed),
                  curve: _sidebarCurve(isCollapsed),
                  width: isCollapsed ? 90 : 280,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: Material(elevation: 0, child: sidebarWidget),
                );
              },
            ),
            const VerticalDivider(width: 1, thickness: 1),
          ],

          Expanded(child: child),
        ],
      ),

      bottomNavigationBar: !isWideLayout ? bottomNavigationBar : null,

      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
