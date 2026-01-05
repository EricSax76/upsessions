import 'package:equatable/equatable.dart';

class HomeEventModel extends Equatable {
  const HomeEventModel({
    required this.id,
    required this.title,
    required this.city,
    required this.venue,
    required this.start,
    required this.description,
    required this.organizer,
    required this.capacity,
    required this.ticketInfo,
    required this.tags,
  });

  final String id;
  final String title;
  final String city;
  final String venue;
  final DateTime start;
  final String description;
  final String organizer;
  final int capacity;
  final String ticketInfo;
  final List<String> tags;

  @override
  List<Object?> get props => [
    id,
    title,
    city,
    venue,
    start,
    description,
    organizer,
    capacity,
    ticketInfo,
    tags,
  ];
}
