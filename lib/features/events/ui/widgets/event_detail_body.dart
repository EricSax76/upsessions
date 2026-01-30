part of '../pages/event_detail_page.dart';

class _EventDetailBody extends StatelessWidget {
  const _EventDetailBody({
    required this.event,
    required this.isUploadingBanner,
    required this.onUploadBanner,
    required this.onCopyTemplate,
    required this.onShare,
  });

  final EventEntity event;
  final bool isUploadingBanner;
  final VoidCallback onUploadBanner;
  final Future<void> Function() onCopyTemplate;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final meta = _buildEventDetailMeta(context, event);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            tooltip: 'Copiar formato',
            onPressed: () => onCopyTemplate(),
            icon: const Icon(Icons.copy_all_outlined),
          ),
          IconButton(
            tooltip: 'Compartir',
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 420
              ? 16.0
              : (constraints.maxWidth < 720 ? 20.0 : 24.0);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: _EventDetailList(
                event: event,
                meta: meta,
                isUploadingBanner: isUploadingBanner,
                onUploadBanner: onUploadBanner,
                onCopyTemplate: onCopyTemplate,
                onShare: onShare,
                horizontalPadding: horizontalPadding,
              ),
            ),
          );
        },
      ),
    );
  }
}
