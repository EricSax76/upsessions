import 'package:cloud_firestore/cloud_firestore.dart';

import 'venue_entity.dart';

class VenueDto {
  const VenueDto({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.province,
    required this.contactEmail,
    required this.contactPhone,
    required this.licenseNumber,
    required this.maxCapacity,
    required this.accessibilityInfo,
    this.postalCode,
    required this.isPublic,
    required this.isActive,
    required this.sourceType,
    this.sourceId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final String city;
  final String province;
  final String? postalCode;
  final String contactEmail;
  final String contactPhone;
  final String licenseNumber;
  final int maxCapacity;
  final String accessibilityInfo;
  final bool isPublic;
  final bool isActive;
  final String sourceType;
  final String? sourceId;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  factory VenueDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return VenueDto(
      id: snapshot.id,
      ownerId: (data['ownerId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      address: (data['address'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      province: (data['province'] as String?) ?? '',
      postalCode: data['postalCode'] as String?,
      contactEmail: (data['contactEmail'] as String?) ?? '',
      contactPhone: (data['contactPhone'] as String?) ?? '',
      licenseNumber: (data['licenseNumber'] as String?) ?? '',
      maxCapacity: (data['maxCapacity'] as num?)?.toInt() ?? 0,
      accessibilityInfo: (data['accessibilityInfo'] as String?) ?? '',
      isPublic: (data['isPublic'] as bool?) ?? true,
      isActive: (data['isActive'] as bool?) ?? true,
      sourceType:
          (data['sourceType'] as String?) ?? VenueSourceType.native.name,
      sourceId: data['sourceId'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  factory VenueDto.fromEntity(VenueEntity entity) {
    return VenueDto(
      id: entity.id,
      ownerId: entity.ownerId,
      name: entity.name,
      description: entity.description,
      address: entity.address,
      city: entity.city,
      province: entity.province,
      postalCode: entity.postalCode,
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      licenseNumber: entity.licenseNumber,
      maxCapacity: entity.maxCapacity,
      accessibilityInfo: entity.accessibilityInfo,
      isPublic: entity.isPublic,
      isActive: entity.isActive,
      sourceType: entity.sourceType.name,
      sourceId: entity.sourceId,
      createdAt: entity.createdAt != null
          ? Timestamp.fromDate(entity.createdAt!)
          : null,
      updatedAt: entity.updatedAt != null
          ? Timestamp.fromDate(entity.updatedAt!)
          : null,
    );
  }

  VenueEntity toEntity() {
    return VenueEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      description: description,
      address: address,
      city: city,
      province: province,
      postalCode: postalCode,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      licenseNumber: licenseNumber,
      maxCapacity: maxCapacity,
      accessibilityInfo: accessibilityInfo,
      isPublic: isPublic,
      isActive: isActive,
      sourceType: VenueSourceType.values.firstWhere(
        (value) => value.name == sourceType,
        orElse: () => VenueSourceType.native,
      ),
      sourceId: sourceId,
      createdAt: createdAt?.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'province': province,
      if (postalCode != null) 'postalCode': postalCode,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'licenseNumber': licenseNumber,
      'maxCapacity': maxCapacity,
      'accessibilityInfo': accessibilityInfo,
      'isPublic': isPublic,
      'isActive': isActive,
      'sourceType': sourceType,
      if (sourceId != null) 'sourceId': sourceId,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
