import 'package:flutter/material.dart';

import '../../../../core/locator/locator.dart';
import '../../logic/liked_musicians_controller.dart';
import '../../models/liked_musician.dart';

class MusicianLikeButton extends StatefulWidget {
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
  State<MusicianLikeButton> createState() => _MusicianLikeButtonState();
}

class _MusicianLikeButtonState extends State<MusicianLikeButton> {
  late final LikedMusiciansController _controller;

  @override
  void initState() {
    super.initState();
    _controller = locate<LikedMusiciansController>();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isLiked = _controller.isLiked(widget.musician.id);
        return IconButton(
          tooltip: isLiked ? 'Quitar de contactos' : 'Añadir a contactos',
          color: isLiked ? colorScheme.primary : null,
          iconSize: widget.iconSize,
          padding: widget.padding ?? EdgeInsets.zero,
          constraints:
              widget.constraints ??
              const BoxConstraints(minHeight: 32, minWidth: 32),
          onPressed: () => _controller.toggleLike(widget.musician),
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
        );
      },
    );
  }
}
