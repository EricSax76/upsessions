import 'dart:async';

import '../domain/musician_entity.dart';

class MusiciansRepository {
  Future<List<MusicianEntity>> search({String query = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (query.isEmpty) {
      return _musicians;
    }
    return _musicians
        .where(
          (musician) => musician.name.toLowerCase().contains(query.toLowerCase()) ||
              musician.styles.any((style) => style.toLowerCase().contains(query.toLowerCase())),
        )
        .toList();
  }

  Future<MusicianEntity?> findById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _musicians.firstWhere((element) => element.id == id);
  }

  static final List<MusicianEntity> _musicians = [
    const MusicianEntity(
      id: '1',
      name: 'María Rivera',
      instrument: 'Voz',
      city: 'CDMX',
      styles: ['Soul', 'R&B'],
      experienceYears: 7,
    ),
    const MusicianEntity(
      id: '2',
      name: 'Juan Herrera',
      instrument: 'Guitarra',
      city: 'Guadalajara',
      styles: ['Rock', 'Alternativo'],
      experienceYears: 10,
    ),
  ];
}
