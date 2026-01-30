import 'package:flutter/foundation.dart';

@immutable
class AnnouncementEntity {
  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.city,
    required this.author,
    required this.authorId,
    required this.province,
    required this.instrument,
    required this.styles,
    required this.publishedAt,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String body;
  final String city;
  final String author;
  /// UID del músico autor
  final String authorId;
  final String province;
  final String instrument;
  final List<String> styles;
  final DateTime publishedAt;
  final String? imageUrl;

  AnnouncementEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? city,
    String? author,
    String? authorId,
    String? province,
    String? instrument,
    List<String>? styles,
    DateTime? publishedAt,
    String? imageUrl,
  }) {
    return AnnouncementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      city: city ?? this.city,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      province: province ?? this.province,
      instrument: instrument ?? this.instrument,
      styles: styles ?? this.styles,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
