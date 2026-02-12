import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import 'app_router_loaders.dart';
import 'app_router_routes.dart';

class AppRouter {
  AppRouter() {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: buildAppRoutes(),
      errorBuilder: (context, state) => UnknownRouteScreen(
        name: state.uri.toString(),
        message: state.error?.toString(),
      ),
    );
  }

  late final GoRouter router;
}
