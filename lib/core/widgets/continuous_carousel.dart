import 'dart:async';
import 'package:flutter/material.dart';

class ContinuousCarousel extends StatefulWidget {
  const ContinuousCarousel({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.scrollSpeed = 30.0, // pixels per second
  });

  final List<Widget> children;

  final double spacing;

  final double scrollSpeed;

  @override
  State<ContinuousCarousel> createState() => _ContinuousCarouselState();
}

class _ContinuousCarouselState extends State<ContinuousCarousel> {
  late final ScrollController _scrollController;
  Timer? _timer;
  bool _isHovering = false;
  final bool _isScrollingFoward = true;

  @override
  void initState() {
    super.initState();
    // Use an initial offset to allow scrolling right away without hitting the hard edge
    _scrollController = ScrollController(initialScrollOffset: 10000.0);

    // Defer the start so layout finishes first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer?.cancel();

    // 60 frames per second = ~16ms per frame
    const fps = 60;
    const durationMs = 1000 ~/ fps;

    _timer = Timer.periodic(const Duration(milliseconds: durationMs), (timer) {
      if (!mounted || _isHovering || !_scrollController.hasClients) return;

      final currentOffset = _scrollController.offset;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final minScroll = _scrollController.position.minScrollExtent;

      // Calculate translation step per frame based on speed
      final step = widget.scrollSpeed / fps;

      double nextOffset = currentOffset + (_isScrollingFoward ? step : -step);

      // Simple edge bounce/wrap if hitting boundaries (though infinite list makes maxScroll huge)
      if (nextOffset >= maxScroll) {
        nextOffset = minScroll + 1000;
        _scrollController.jumpTo(nextOffset);
        return;
      }
      if (nextOffset <= minScroll) {
        nextOffset = maxScroll - 1000;
        _scrollController.jumpTo(nextOffset);
        return;
      }

      _scrollController.jumpTo(nextOffset);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onPanDown: (_) => setState(() => _isHovering = true),
        onPanCancel: () => setState(() => _isHovering = false),
        onPanEnd: (_) => setState(() => _isHovering = false),
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          // Massive itemCount to simulate infinite scrolling
          itemCount: 1000000,
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (context, index) => SizedBox(width: widget.spacing),
          itemBuilder: (context, index) {
            final actualIndex = index % widget.children.length;
            return widget.children[actualIndex];
          },
        ),
      ),
    );
  }
}
