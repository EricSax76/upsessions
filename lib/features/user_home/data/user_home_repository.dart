import 'dart:async';

import 'announcement_model.dart';
import 'instrument_category_model.dart';
import 'musician_card_model.dart';

class UserHomeRepository {
  Future<List<MusicianCardModel>> fetchRecommendedMusicians() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _musicians.take(6).toList();
  }

  Future<List<MusicianCardModel>> fetchNewMusicians() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _musicians.reversed.take(4).toList();
  }

  Future<List<AnnouncementModel>> fetchRecentAnnouncements() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    return _announcements;
  }

  Future<List<InstrumentCategoryModel>> fetchInstrumentCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _categories;
  }

  Future<List<String>> fetchProvinces() async {
    return const ['CDMX', 'Jalisco', 'Monterrey', 'Yucatán', 'Baja California'];
  }

  static final List<MusicianCardModel> _musicians = [
    const MusicianCardModel(
      id: '1',
      name: 'María Rivera',
      instrument: 'Voz',
      location: 'Ciudad de México',
      style: 'Soul',
      rating: 4.9,
    ),
    const MusicianCardModel(
      id: '2',
      name: 'Juan Herrera',
      instrument: 'Guitarra',
      location: 'Guadalajara',
      style: 'Rock',
      rating: 4.6,
    ),
    const MusicianCardModel(
      id: '3',
      name: 'Luisa Méndez',
      instrument: 'Batería',
      location: 'Monterrey',
      style: 'Pop',
      rating: 4.4,
    ),
    const MusicianCardModel(
      id: '4',
      name: 'Rafa Lozano',
      instrument: 'Bajo',
      location: 'Puebla',
      style: 'Funk',
      rating: 4.5,
    ),
    const MusicianCardModel(
      id: '5',
      name: 'Diana Cárdenas',
      instrument: 'Teclado',
      location: 'Cancún',
      style: 'Indie',
      rating: 4.7,
    ),
    const MusicianCardModel(
      id: '6',
      name: 'Diego Flores',
      instrument: 'Saxofón',
      location: 'Tijuana',
      style: 'Jazz',
      rating: 4.8,
    ),
  ];

  static final List<AnnouncementModel> _announcements = [
    AnnouncementModel(
      id: 'a1',
      title: 'Buscamos vocalista femenina',
      description: 'Proyecto pop latino con fechas confirmadas.',
      city: 'CDMX',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AnnouncementModel(
      id: 'a2',
      title: 'Guitarrista rítmico para banda de funk',
      description: 'Ensayos dos veces por semana, experiencia mínima de 2 años.',
      city: 'Guadalajara',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static final List<InstrumentCategoryModel> _categories = [
    const InstrumentCategoryModel(category: 'Cuerdas', instruments: ['Guitarra', 'Bajo', 'Violin']),
    const InstrumentCategoryModel(category: 'Viento', instruments: ['Saxofón', 'Trompeta']),
    const InstrumentCategoryModel(category: 'Percusión', instruments: ['Batería', 'Congas', 'Cajón']),
  ];
}
