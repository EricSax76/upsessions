import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_link_scheme.dart';

class AppLinksListener extends StatefulWidget {
  const AppLinksListener({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  State<AppLinksListener> createState() => _AppLinksListenerState();
}

class _AppLinksListenerState extends State<AppLinksListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final initial = await _appLinks.getInitialLink();
      final initialLocation = _locationFromUri(initial);
      if (initialLocation != null) {
        widget.router.go(initialLocation);
      }
    } catch (_) {}

    _sub = _appLinks.uriLinkStream.listen((uri) {
      final location = _locationFromUri(uri);
      if (location == null) return;
      widget.router.go(location);
    });
  }

  String? _locationFromUri(Uri? uri) {
    if (uri == null) return null;
    if (uri.scheme != appLinkScheme) return null;

    // Support both:
    // - com.example.musicintouch:///invite?groupId=...&inviteId=...
    // - com.example.musicintouch://invite?groupId=...&inviteId=...
    final path = uri.path.isNotEmpty ? uri.path : '/${uri.host}';
    if (path.isEmpty || path == '/') return null;

    final query = uri.query;
    return query.isEmpty ? path : '$path?$query';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
