import 'package:flutter/foundation.dart';

@immutable
class MusicianCardModel {
  const MusicianCardModel({
    required this.id,
    required this.name,
    required this.instrument,
    required this.location,
    required this.style,
    this.avatarUrl,
    this.rating = 0,
  });

  final String id;
  final String name;
  final String instrument;
  final String location;
  final String style;
  final String? avatarUrl;
  final double rating;
}
