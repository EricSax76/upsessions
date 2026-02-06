import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../models/studio_entity.dart';

class StudioCard extends StatelessWidget {
  const StudioCard({
    super.key,
    required this.studio,
    required this.onTap,
  });

  final StudioEntity studio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasBanner = studio.bannerUrl != null && studio.bannerUrl!.isNotEmpty;
    final hasLogo = studio.logoUrl != null && studio.logoUrl!.isNotEmpty;

    return AppCard(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Image Area
          SizedBox(
            height: 140,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasBanner)
                  Image.network(
                    studio.bannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: scheme.surfaceContainerHighest),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                       gradient: LinearGradient(
                        colors: [
                          scheme.primaryContainer,
                          scheme.surfaceContainerHighest,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.storefront,
                        size: 48,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Logo (if available) floating
                if (hasLogo)
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(studio.logoUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studio.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                             maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: scheme.secondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  studio.address,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action Arrow
                     Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward, size: 16, color: scheme.onSurface),
                    ),
                  ],
                ),
                 const SizedBox(height: 12),
                 // View Rooms Button-like look (optional, maybe redundant with arrow but good for explicit CTA)
                 Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Text(
                      'View Rooms',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
