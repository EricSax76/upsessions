import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
// import 'package:upsessions/core/locator/locator.dart';
// import 'package:upsessions/features/messaging/repositories/chat_repository.dart';

// import 'package:upsessions/features/notifications/repositories/invite_notifications_repository.dart';
import '../../../notifications/cubits/notifications_status_cubit.dart';
import 'notification_badge.dart';

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsStatusCubit, int>(
      builder: (context, unreadTotal) {
        return IconButton(
          onPressed: () => context.push(AppRoutes.notifications),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              if (unreadTotal > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: NotificationBadge(
                    count: unreadTotal,
                    showBorder: true,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
