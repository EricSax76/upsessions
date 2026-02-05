import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../auth/cubits/auth_cubit.dart';
import 'studio_sidebar.dart';

/// Shell page for studio session that provides sidebar navigation
class StudioShellPage extends StatelessWidget {
  const StudioShellPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWideLayout = kIsWeb ? width >= 700 : width >= 1200;

    Widget body;
    if (isWideLayout) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 300,
            child: Material(
              elevation: 0,
              child: StudioSidebar(),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Scaffold(
              body: child,
            ),
          ),
        ],
      );
    } else {
      // Logic for Web Mobile (< 700px) to show Hamburger without AppBar
      if (kIsWeb) {
        body = Stack(
          children: [
            child,
            Positioned(
              top: 12,
              left: 12,
              child: SafeArea(
                child: Builder(
                  builder: (context) => FloatingActionButton.small(
                    heroTag: 'studio_hamburger_fab',
                    elevation: 2,
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        body = child;
      }
    }

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.studiosLogin);
        }
      },
      child: Scaffold(
        drawer: isWideLayout
            ? null
            : const Drawer(
                child: SafeArea(child: StudioSidebar()),
              ),
        appBar: isWideLayout || kIsWeb
            ? null
            : AppBar(
                title: const Text('Panel de Estudio'),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
        body: body,
      ),
    );
  }
}
