import 'package:cloud_firestore/cloud_firestore.dart';
import 'gig_offer_entity.dart';

class GigOfferDto {
  const GigOfferDto({
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

  final String id;
  final String managerId;
  final String title;
  final String description;
  final List<String> instrumentRequirements;
  final Timestamp? date;
  final String time;
  final String location;
  final String? budget;
  final String status;
  final List<String> applicants;
  final Timestamp? createdAt;

  factory GigOfferDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return GigOfferDto(
      id: snapshot.id,
      managerId: data['managerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      instrumentRequirements: List<String>.from(data['instrumentRequirements'] ?? []),
      date: data['date'] as Timestamp?,
      time: data['time'] as String? ?? '',
      location: data['location'] as String? ?? '',
      budget: data['budget'] as String?,
      status: data['status'] as String? ?? 'open',
      applicants: List<String>.from(data['applicants'] ?? []),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  factory GigOfferDto.fromEntity(GigOfferEntity entity) {
    return GigOfferDto(
      id: entity.id,
      managerId: entity.managerId,
      title: entity.title,
      description: entity.description,
      instrumentRequirements: entity.instrumentRequirements,
      date: entity.date != null ? Timestamp.fromDate(entity.date!) : null,
      time: entity.time,
      location: entity.location,
      budget: entity.budget,
      status: entity.status.name,
      applicants: entity.applicants,
      createdAt: entity.createdAt != null ? Timestamp.fromDate(entity.createdAt!) : null,
    );
  }

  GigOfferEntity toEntity() {
    return GigOfferEntity(
      id: id,
      managerId: managerId,
      title: title,
      description: description,
      instrumentRequirements: instrumentRequirements,
      date: date?.toDate(),
      time: time,
      location: location,
      budget: budget,
      status: GigOfferStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => GigOfferStatus.open,
      ),
      applicants: applicants,
      createdAt: createdAt?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'managerId': managerId,
      'title': title,
      'description': description,
      'instrumentRequirements': instrumentRequirements,
      'date': date,
      'time': time,
      'location': location,
      if (budget != null) 'budget': budget,
      'status': status,
      'applicants': applicants,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
