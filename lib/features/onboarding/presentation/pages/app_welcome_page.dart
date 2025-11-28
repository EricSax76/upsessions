import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';

class AppWelcomePage extends StatelessWidget {
  const AppWelcomePage({super.key});

  static const Color _wineRed = Color(0xFF5A0A16);

  void _continue(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingStoryOne);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => _continue(context),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_wineRed, Color(0xFF24040A)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'UPSESSIONS',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Conecta tu música\ncon nuevas sesiones.',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: () => _continue(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _wineRed,
                    ),
                    child: const Text('Comenzar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
