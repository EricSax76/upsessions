import 'package:flutter/material.dart';

import '../../../../core/locator/locator.dart';
import '../../application/liked_musicians_controller.dart';
import '../../models/liked_musician.dart';

class MusicianLikeButton extends StatelessWidget {
  const MusicianLikeButton({
    super.key,
    required this.musician,
    this.iconSize = 20,
    this.padding,
    this.constraints,
  });

  final LikedMusician musician;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final controller = locate<LikedMusiciansController>();
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isLiked = controller.isLiked(musician.id);
        return IconButton(
          tooltip: isLiked ? 'Quitar de contactos' : 'Añadir a contactos',
          color: isLiked ? colorScheme.primary : null,
          iconSize: iconSize,
          padding: padding ?? EdgeInsets.zero,
          constraints:
              constraints ?? const BoxConstraints(minHeight: 32, minWidth: 32),
          onPressed: () => controller.toggleLike(musician),
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
        );
      },
    );
  }
}
