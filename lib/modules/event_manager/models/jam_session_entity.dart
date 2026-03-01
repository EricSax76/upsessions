import 'package:equatable/equatable.dart';

class JamSessionEntity extends Equatable {
  const JamSessionEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.city,
    this.coverImageUrl,
    this.instrumentRequirements = const [],
    this.isCanceled = false,
  });

  const JamSessionEntity.empty()
      : id = '',
        ownerId = '',
        title = '',
        description = '',
        date = null,
        time = '',
        location = '',
        city = '',
        coverImageUrl = null,
        instrumentRequirements = const [],
        isCanceled = false;

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final DateTime? date;
  final String time;
  final String location;
  final String city;
  final String? coverImageUrl;
  final List<String> instrumentRequirements;
  final bool isCanceled;

  JamSessionEntity copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? city,
    String? coverImageUrl,
    List<String>? instrumentRequirements,
    bool? isCanceled,
  }) {
    return JamSessionEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      city: city ?? this.city,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      instrumentRequirements: instrumentRequirements ?? this.instrumentRequirements,
      isCanceled: isCanceled ?? this.isCanceled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        date,
        time,
        location,
        city,
        coverImageUrl,
        instrumentRequirements,
        isCanceled,
      ];
}
