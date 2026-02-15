import 'package:flutter/material.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';
import '../../models/studio_entity.dart';

class StudioProfileHeader extends StatelessWidget {
  const StudioProfileHeader({
    super.key,
    required this.studio,
    required this.onUploadBanner,
    required this.onUploadLogo,
    required this.onExit,
  });

  final StudioEntity studio;
  final VoidCallback onUploadBanner;
  final VoidCallback onUploadLogo;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Volver',
        onPressed: onExit,
      ),
      title: const Text('Perfil del Estudio'),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (studio.bannerUrl != null && studio.bannerUrl!.isNotEmpty)
              Image.network(
                studio.bannerUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: Colors.black26,
                  ),
                ),
              )
            else
              Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.image, size: 64, color: Colors.black26),
              ),
            Positioned(
              bottom: 8,
              right: 8,
              child: FloatingActionButton.small(
                heroTag: 'banner',
                onPressed: onUploadBanner,
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Space for half avatar
        child: Container(),
      ),
    );
  }
}

class StudioAvatarSection extends StatelessWidget {
  const StudioAvatarSection({
    super.key,
    required this.studio,
    required this.onUploadLogo,
  });

  final StudioEntity studio;
  final VoidCallback onUploadLogo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: SmAvatar(
              radius: 50,
              imageUrl: studio.logoUrl,
              fallbackIcon: Icons.store,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: onUploadLogo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
