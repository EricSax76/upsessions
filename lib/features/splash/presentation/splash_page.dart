import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/firebase_initializer.dart';
import '../../auth/data/auth_repository.dart';
import '../../musicians/data/musicians_repository.dart';
import '../application/bootstrap_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BootstrapCubit(
        firebaseInitializer: context.read<FirebaseInitializer>(),
        authRepository: context.read<AuthRepository>(),
        musiciansRepository: context.read<MusiciansRepository>(),
      )..initialize(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BootstrapCubit, BootstrapState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == BootstrapStatus.authenticated) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.userHome);
        } else if (state.status == BootstrapStatus.needsOnboarding) {
          Navigator.of(
            context,
          ).pushReplacementNamed(AppRoutes.musicianOnboarding);
        } else if (state.status == BootstrapStatus.needsLogin) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
        }
      },
      builder: (context, state) {
        final showError =
            state.status == BootstrapStatus.error && state.errorMessage != null;
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 88),
                const SizedBox(height: 16),
                if (state.status == BootstrapStatus.loading)
                  const CircularProgressIndicator()
                else if (showError)
                  const Icon(
                    Icons.error_outline,
                    size: 32,
                    color: Colors.redAccent,
                  )
                else
                  const Icon(Icons.music_note, size: 32),
                if (showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
