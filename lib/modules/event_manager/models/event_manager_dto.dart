import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_manager_entity.dart';

class EventManagerDto {
  EventManagerDto({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.contactEmail,
    required this.contactPhone,
    required this.city,
    this.province,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.website,
    required this.specialties,
  });

  factory EventManagerDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return EventManagerDto(
      id: snapshot.id,
      ownerId: (data['ownerId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      contactEmail: (data['contactEmail'] as String?) ?? '',
      contactPhone: (data['contactPhone'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      province: data['province'] as String?,
      description: data['description'] as String?,
      logoUrl: data['logoUrl'] as String?,
      bannerUrl: data['bannerUrl'] as String?,
      website: data['website'] as String?,
      specialties: _stringList(data['specialties']),
    );
  }

  factory EventManagerDto.fromEntity(EventManagerEntity entity) {
    return EventManagerDto(
      id: entity.id,
      ownerId: entity.ownerId,
      name: entity.name,
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      city: entity.city,
      province: entity.province,
      description: entity.description,
      logoUrl: entity.logoUrl,
      bannerUrl: entity.bannerUrl,
      website: entity.website,
      specialties: entity.specialties,
    );
  }

  final String id;
  final String ownerId;
  final String name;
  final String contactEmail;
  final String contactPhone;
  final String city;
  final String? province;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? website;
  final List<String> specialties;

  EventManagerEntity toEntity() {
    return EventManagerEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      city: city,
      province: province,
      description: description,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      website: website,
      specialties: specialties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'name': name,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'city': city,
      if (province != null) 'province': province,
      if (description != null) 'description': description,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (bannerUrl != null) 'bannerUrl': bannerUrl,
      if (website != null) 'website': website,
      'specialties': specialties,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

List<String> _stringList(dynamic value) {
  if (value is Iterable) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}
