import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/sm_avatar.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
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
      body = child;
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
        appBar: isWideLayout
            ? null
            : AppBar(
                centerTitle: true,
                title: AppLogo(
                  label: 'UpSessions',
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  iconSize: 22,
                ),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: BlocBuilder<StudiosCubit, StudiosState>(
                      builder: (context, state) {
                        final studio = state.myStudio;
                        final name = studio?.name ?? '';
                        final initials =
                            name.trim().isEmpty ? '' : name.trim()[0];
                        return InkWell(
                          onTap: () {
                            context.push(
                              '/studios/profile',
                              extra: context.read<StudiosCubit>(),
                            );
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: SmAvatar(
                            radius: 16,
                            imageUrl: studio?.logoUrl,
                            initials: initials,
                            fallbackIcon: Icons.store_outlined,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        body: body,
      ),
    );
  }
}
