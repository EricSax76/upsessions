import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/announcement_entity.dart';

class AnnouncementDto {
  const AnnouncementDto({
    required this.id,
    required this.title,
    required this.body,
    required this.city,
    required this.author,
    required this.publishedAt,
  });

  factory AnnouncementDto.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AnnouncementDto(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      body: (data['body'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      author: (data['author'] ?? '') as String,
      publishedAt: _parseDate(data['publishedAt']),
    );
  }

  factory AnnouncementDto.fromEntity(AnnouncementEntity entity) {
    return AnnouncementDto(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      city: entity.city,
      author: entity.author,
      publishedAt: entity.publishedAt,
    );
  }

  final String id;
  final String title;
  final String body;
  final String city;
  final String author;
  final DateTime publishedAt;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'city': city,
      'author': author,
      'publishedAt': Timestamp.fromDate(publishedAt),
    };
  }

  AnnouncementEntity toEntity() {
    return AnnouncementEntity(
      id: id,
      title: title,
      body: body,
      city: city,
      author: author,
      publishedAt: publishedAt,
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
}
