import 'package:equatable/equatable.dart';

enum GigOfferStatus { open, closed }

class GigOfferEntity extends Equatable {
  const GigOfferEntity({
    required this.id,
    required this.managerId,
    required this.title,
    required this.description,
    required this.instrumentRequirements,
    required this.date,
    required this.time,
    required this.location,
    this.budget,
    required this.status,
    required this.applicants,
    required this.createdAt,
  });

  const GigOfferEntity.empty()
      : id = '',
        managerId = '',
        title = '',
        description = '',
        instrumentRequirements = const [],
        date = null,
        time = '',
        location = '',
        budget = null,
        status = GigOfferStatus.open,
        applicants = const [],
        createdAt = null;

  final String id;
  final String managerId;
  final String title;
  final String description;
  final List<String> instrumentRequirements;
  final DateTime? date;
  final String time;
  final String location;
  final String? budget;
  final GigOfferStatus status;
  final List<String> applicants; // list of musicianIds
  final DateTime? createdAt;

  GigOfferEntity copyWith({
    String? id,
    String? managerId,
    String? title,
    String? description,
    List<String>? instrumentRequirements,
    DateTime? date,
    String? time,
    String? location,
    String? budget,
    GigOfferStatus? status,
    List<String>? applicants,
    DateTime? createdAt,
  }) {
    return GigOfferEntity(
      id: id ?? this.id,
      managerId: managerId ?? this.managerId,
      title: title ?? this.title,
      description: description ?? this.description,
      instrumentRequirements: instrumentRequirements ?? this.instrumentRequirements,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      applicants: applicants ?? this.applicants,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        managerId,
        title,
        description,
        instrumentRequirements,
        date,
        time,
        location,
        budget,
        status,
        applicants,
        createdAt,
      ];
}
