import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/liked_musicians_cubit.dart';
import '../../cubits/liked_musicians_state.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<LikedMusiciansCubit, LikedMusiciansState>(
      buildWhen: (previous, current) =>
          previous.isLiked(musician.id) != current.isLiked(musician.id),
      builder: (context, state) {
        final isLiked = state.isLiked(musician.id);
        return IconButton(
          tooltip: isLiked ? 'Quitar de contactos' : 'Añadir a contactos',
          color: isLiked ? colorScheme.primary : null,
          iconSize: iconSize,
          padding: padding ?? EdgeInsets.zero,
          constraints: constraints ??
              const BoxConstraints(minHeight: 32, minWidth: 32),
          onPressed: () =>
              context.read<LikedMusiciansCubit>().toggleLike(musician),
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
        );
      },
    );
  }
}
