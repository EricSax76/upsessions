import 'package:flutter/foundation.dart';

@immutable
class AnnouncementEntity {
  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.city,
    required this.author,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String body;
  final String city;
  final String author;
  final DateTime publishedAt;
}
