import 'package:flutter/material.dart';

class SmAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SmAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Solo Músicos'),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        const CircleAvatar(child: Icon(Icons.person)),
        const SizedBox(width: 12),
      ],
    );
  }
}
