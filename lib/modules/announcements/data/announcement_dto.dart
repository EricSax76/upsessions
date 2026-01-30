import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/announcement_entity.dart';

class AnnouncementDto {
  const AnnouncementDto({
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

  factory AnnouncementDto.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AnnouncementDto(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      body: (data['body'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      author: (data['author'] ?? '') as String,
      authorId: (data['authorId'] ?? '') as String,
      province: (data['province'] ?? '') as String,
      instrument: (data['instrument'] ?? '') as String,
      styles: _stringList(data['styles']),
      publishedAt: _parseDate(data['publishedAt']),
      imageUrl: (data['imageUrl'] ?? '') as String?,
    );
  }

  factory AnnouncementDto.fromEntity(AnnouncementEntity entity) {
    return AnnouncementDto(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      city: entity.city,
      author: entity.author,
      authorId: entity.authorId,
      province: entity.province,
      instrument: entity.instrument,
      styles: entity.styles,
      publishedAt: entity.publishedAt,
      imageUrl: entity.imageUrl,
    );
  }

  final String id;
  final String title;
  final String body;
  final String city;
  final String author;
  final String authorId;
  final String province;
  final String instrument;
  final List<String> styles;
  final DateTime publishedAt;
  final String? imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'city': city,
      'author': author,
      'authorId': authorId,
      'province': province,
      'instrument': instrument,
      'styles': styles,
      'publishedAt': Timestamp.fromDate(publishedAt),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  AnnouncementEntity toEntity() {
    return AnnouncementEntity(
      id: id,
      title: title,
      body: body,
      city: city,
      author: author,
      authorId: authorId,
      province: province,
      instrument: instrument,
      styles: styles,
      publishedAt: publishedAt,
      imageUrl: imageUrl,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
