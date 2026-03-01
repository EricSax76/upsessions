import 'package:equatable/equatable.dart';

class EventManagerEntity extends Equatable {
  const EventManagerEntity({
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

  EventManagerEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? contactEmail,
    String? contactPhone,
    String? city,
    String? province,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    String? website,
    List<String>? specialties,
  }) {
    return EventManagerEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      city: city ?? this.city,
      province: province ?? this.province,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      website: website ?? this.website,
      specialties: specialties ?? this.specialties,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        contactEmail,
        contactPhone,
        city,
        province,
        description,
        logoUrl,
        bannerUrl,
        website,
        specialties,
      ];
}
