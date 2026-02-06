import 'package:flutter/material.dart';
import '../../../../core/constants/app_layout.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String? title;
  final VoidCallback? onBackPressed;

  const AuthLayout({
    super.key,
    required this.child,
    this.showAppBar = false,
    this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isCompact =
        media.size.width < 400 || media.size.height < 720;
    final outerPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
        : const EdgeInsets.all(24);
    final cardPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 18, vertical: 18)
        : const EdgeInsets.all(24);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: title != null ? Text(title!) : null,
              leading: onBackPressed != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBackPressed,
                    )
                  : null,
            )
          : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/logos/upsessions_foto_login.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Theme.of(context).colorScheme.primaryContainer,
              );
            },
          ),
          // Opacity Overlay
          Container(
            color: Colors.black.withValues(alpha: 0.7), // Adjust opacity as needed
          ),
          // Centered Card Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: outerPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.maxAuthFormWidth,
                  ),
                  child: Container(
                    padding: cardPadding,
                    decoration: BoxDecoration(
                      // Transparent background for the card as requested
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                         color: Colors.white.withValues(alpha: 0.2),
                         width: 1,
                      ),
                    ),
                    // Ensure text color contrasts with dark background
                    child: Theme(
                      data: Theme.of(context).copyWith(
                         brightness: Brightness.dark, 
                         colorScheme: Theme.of(context).colorScheme.copyWith(
                            brightness: Brightness.dark,
                         ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
