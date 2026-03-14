import 'package:equatable/equatable.dart';

/// Shared venue catalog entity for event managers and musicians.
class VenueEntity extends Equatable {
  const VenueEntity({
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
    this.isPublic = true,
    this.isActive = true,
    this.sourceType = VenueSourceType.native,
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
  final VenueSourceType sourceType;
  final String? sourceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isStudioBacked => sourceType == VenueSourceType.studio;

  VenueEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? contactEmail,
    String? contactPhone,
    String? licenseNumber,
    int? maxCapacity,
    String? accessibilityInfo,
    bool? isPublic,
    bool? isActive,
    VenueSourceType? sourceType,
    String? sourceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VenueEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      accessibilityInfo: accessibilityInfo ?? this.accessibilityInfo,
      isPublic: isPublic ?? this.isPublic,
      isActive: isActive ?? this.isActive,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    description,
    address,
    city,
    province,
    postalCode,
    contactEmail,
    contactPhone,
    licenseNumber,
    maxCapacity,
    accessibilityInfo,
    isPublic,
    isActive,
    sourceType,
    sourceId,
    createdAt,
    updatedAt,
  ];
}

enum VenueSourceType { native, studio }
