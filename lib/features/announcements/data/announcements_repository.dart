import 'dart:async';

import '../domain/announcement_entity.dart';

class AnnouncementsRepository {
  Future<List<AnnouncementEntity>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _announcements;
  }

  Future<AnnouncementEntity> findById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _announcements.firstWhere((element) => element.id == id);
  }

  Future<void> create(AnnouncementEntity entity) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _announcements.add(entity);
  }

  static final List<AnnouncementEntity> _announcements = [
    AnnouncementEntity(
      id: 'a1',
      title: 'Busco tecladista para tour',
      body: 'Repertorio pop, ensayos en CDMX.',
      city: 'CDMX',
      author: 'María Rivera',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AnnouncementEntity(
      id: 'a2',
      title: 'Productor busca vocalista',
      body: 'Proyecto soul con experiencias pagadas.',
      city: 'Guadalajara',
      author: 'Alex Soto',
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}
