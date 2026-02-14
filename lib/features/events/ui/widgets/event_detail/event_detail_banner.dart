import 'package:flutter/material.dart';

/// Widget que muestra el banner del evento con opción de subir/cambiar imagen
class EventBanner extends StatelessWidget {
  const EventBanner({
    super.key,
    required this.imageUrl,
    required this.isUploading,
    required this.onUpload,
    required this.eventTitle,
  });

  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onUpload;
  final String eventTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: hasImage ? 4 : 0,
      child: Stack(
        children: [
          // Imagen de fondo o placeholder con gradiente
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: hasImage
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primaryContainer,
                        scheme.secondaryContainer,
                        scheme.tertiaryContainer,
                      ],
                    ),
            ),
            child: hasImage
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.errorContainer,
                              scheme.primaryContainer,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 64,
                            color: scheme.onErrorContainer.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : null,
          ),

          // Overlay con gradiente para mejor legibilidad
          if (hasImage)
            Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),

          // Contenido
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Título del evento con efecto glassmorphism
                  if (hasImage)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        eventTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  if (!hasImage)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: scheme.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dale un toque de exclusividad',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sube un banner personalizado para este evento',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onPrimaryContainer.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Botón de subir/cambiar imagen
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: hasImage
                  ? Colors.white.withValues(alpha: 0.25)
                  : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              elevation: hasImage ? 0 : 2,
              child: InkWell(
                onTap: isUploading ? null : onUpload,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: hasImage
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        )
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUploading)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: hasImage ? Colors.white : scheme.primary,
                          ),
                        )
                      else
                        Icon(
                          hasImage
                              ? Icons.edit_outlined
                              : Icons.add_photo_alternate_outlined,
                          size: 20,
                          color: hasImage
                              ? Colors.white
                              : scheme.onPrimaryContainer,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isUploading
                            ? 'Subiendo...'
                            : (hasImage ? 'Cambiar' : 'Subir banner'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: hasImage
                              ? Colors.white
                              : scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
