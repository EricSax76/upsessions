import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../auth/domain/user_entity.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/auth_exceptions.dart';
import '../application/splash_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashController _controller = SplashController();
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _controller.initialize();
    if (!mounted) return;
    try {
      final UserEntity user = await _authRepository.signIn('solista@example.com', 'token');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(user.isVerified ? AppRoutes.userHome : AppRoutes.login);
    } on AuthException {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 88),
                const SizedBox(height: 16),
                _controller.isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.music_note, size: 32),
                if (_controller.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _controller.error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
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
