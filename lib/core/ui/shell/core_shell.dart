import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A standardized shell widget that handles responsive layout for web and mobile.
///
/// It automatically manages:
/// - Sidebar placement (Row on wide screens, Drawer on small screens)
/// - BottomNavigationBar visibility (Hidden on wide screens)
/// - AppBar display logic (can be customized)
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

  /// The main content of the page.
  final Widget child;

  /// The sidebar widget.
  /// - On wide screens: Displayed permanently on the left.
  /// - On small screens: Displayed in a Drawer.
  final Widget? sidebar;

  /// The application bar.
  /// If provided, it will be shown based on standard behavior.
  /// Typically, you might want to hide the standard AppBar on wide layouts if the sidebar handles navigation,
  /// but this widget simply renders it if provided in the Scaffold parameters (or internal logic).
  ///
  /// However, to support the specific logic of UserShellPage (hide top app bar on wide/web if desired),
  /// the caller should control whether they pass an AppBar or not.
  ///
  /// NOTE: UserShellPage had logic: `showTopAppBar = kIsWeb || !isWideLayout`.
  /// Here we just take the widget. Caller decides creation.
  final PreferredSizeWidget? appBar;

  /// The bottom navigation bar.
  /// Automatically hidden on wide screens where the sidebar is visible.
  final Widget? bottomNavigationBar;

  /// The floating action button.
  final Widget? floatingActionButton;

  /// Location of the FAB.
  final FloatingActionButtonLocation floatingActionButtonLocation;

  /// Breakpoint width for mobile layout (used primarily for Web).
  final double mobileBreakpoint;

  /// Breakpoint width for desktop layout (used for non-web platforms usually, or general wide logic).
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Logic extracted from UserShellPage:
    // final isWideLayout = kIsWeb ? width >= 700 : width >= 1200;
    final isWideLayout = kIsWeb ? width >= mobileBreakpoint : width >= desktopBreakpoint;

    return Scaffold(
      // Drawer is only shown if sidebar is provided and we are NOT in wide layout
      drawer: (!isWideLayout && sidebar != null)
          ? Drawer(child: SafeArea(child: sidebar!))
          : null,
      
      appBar: appBar,
      
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permanent Sidebar on wide layout
          if (isWideLayout && sidebar != null) ...[
            SizedBox(
              width: 300,
              child: Material(
                elevation: 0,
                // Ensure sidebar backgrounds etc match design
                child: sidebar!,
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
          ],
          
          // Main Content
          Expanded(
            child: child,
          ),
        ],
      ),
      
      // Bottom Nav only on small screens
      bottomNavigationBar: !isWideLayout ? bottomNavigationBar : null,
      
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
