import 'package:flutter/foundation.dart';

@immutable
class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.date,
  });

  final String id;
  final String title;
  final String description;
  final String city;
  final DateTime date;
}
