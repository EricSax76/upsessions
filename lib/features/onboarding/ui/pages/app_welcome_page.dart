import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class AppWelcomePage extends StatelessWidget {
  const AppWelcomePage({
    super.key,
    required this.onContinue,
    this.onSkip,
  });

  static const Color _wineRed = Color(0xFF5A0A16);

  final VoidCallback onContinue;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: GestureDetector(
        onTap: onContinue,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 23, 113, 151), Color(0xFF24040A)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                if (onSkip != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: onSkip,
                      child: Text(loc.skip),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        loc.appBrandName,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.appWelcomeTagline,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      FilledButton(
                        onPressed: onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _wineRed,
                        ),
                        child: Text(loc.startButton),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
