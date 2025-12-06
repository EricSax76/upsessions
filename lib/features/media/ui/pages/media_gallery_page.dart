import 'package:flutter/material.dart';

import 'package:upsessions/core/locator/locator.dart';
import '../../data/repositories/media_repository.dart';
import '../../domain/media_item.dart';
import '../widgets/media_grid.dart';

class MediaGalleryPage extends StatefulWidget {
  const MediaGalleryPage({super.key});

  @override
  State<MediaGalleryPage> createState() => _MediaGalleryPageState();
}

class _MediaGalleryPageState extends State<MediaGalleryPage> {
  final MediaRepository _repository = locate();
  List<MediaItem> _media = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repository.fetchMedia();
    setState(() => _media = items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galería')),
      body: MediaGrid(items: _media),
    );
  }
}
