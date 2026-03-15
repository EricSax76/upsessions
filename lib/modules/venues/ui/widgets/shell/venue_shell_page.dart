import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/features/home/ui/widgets/legal/legal_compliance_gate.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/ui/shell/core_shell.dart';
import '../../../../../core/ui/shell/sidebar_cubit.dart';
import '../../../../../core/widgets/app_logo.dart';
import '../../../../../core/widgets/sm_avatar.dart';
import '../../../../auth/cubits/auth_cubit.dart';
import 'venue_bottom_nav.dart';
import 'venue_sidebar.dart';

class VenueShellPage extends StatelessWidget {
  const VenueShellPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWideLayout = kIsWeb ? width >= 700 : width >= 1200;
    final showTopAppBar = kIsWeb || !isWideLayout;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.venuesAuthLogin);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final localizations = AppLocalizations.of(context);
          final user = state.user;
          final name = user?.displayName ?? '';
          final initials = name.trim().isEmpty ? '' : name.trim()[0];

          return BlocProvider<SidebarCubit>(
            create: (_) => SidebarCubit(),
            child: CoreShell(
              sidebar: const VenueSidebar(),
              bottomNavigationBar: const VenueBottomNav(),
              appBar: showTopAppBar
                  ? AppBar(
                      centerTitle: true,
                      title: AppLogo(
                        label: localizations.venueShellBrandName,
                        textStyle: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        iconSize: 22,
                      ),
                      leading: isWideLayout
                          ? null
                          : Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                              ),
                            ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: InkWell(
                            onTap: () => context.go(AppRoutes.settings),
                            borderRadius: BorderRadius.circular(24),
                            child: SmAvatar(
                              radius: 16,
                              imageUrl: user?.photoUrl,
                              initials: initials,
                              fallbackIcon: Icons.store_outlined,
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
              child: LegalComplianceGate(child: child),
            ),
          );
        },
      ),
    );
  }
}
