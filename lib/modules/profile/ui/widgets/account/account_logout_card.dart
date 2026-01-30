import 'package:flutter/material.dart';

class AccountLogoutCard extends StatelessWidget {
  const AccountLogoutCard({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      // ignore: deprecated_member_use
      color: Theme.of(
        context,
        // ignore: deprecated_member_use
      ).colorScheme.errorContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          // ignore: deprecated_member_use
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.logout,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          'Cerrar sesión',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onSignOut,
      ),
    );
  }
}
