import 'package:flutter/material.dart';

class JamSessionDetailBanner extends StatelessWidget {
  const JamSessionDetailBanner({super.key, required this.coverImageUrl});

  final String? coverImageUrl;

  @override
  Widget build(BuildContext context) {
    if (coverImageUrl != null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(coverImageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.music_note,
        size: 64,
        color: Theme.of(context).colorScheme.onTertiaryContainer,
      ),
    );
  }
}
