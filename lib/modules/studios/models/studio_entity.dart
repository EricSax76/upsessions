import 'package:equatable/equatable.dart';

class StudioEntity extends Equatable {
  const StudioEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    required this.cif,
    required this.businessName,
    this.logoUrl,
    this.bannerUrl,
  });

  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String cif;
  final String businessName;
  final String? logoUrl;
  final String? bannerUrl;

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        description,
        address,
        contactEmail,
        contactPhone,
        cif,
        businessName,
        logoUrl,
        bannerUrl,
      ];

  StudioEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? cif,
    String? businessName,
    String? logoUrl,
    String? bannerUrl,
  }) {
    return StudioEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      cif: cif ?? this.cif,
      businessName: businessName ?? this.businessName,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
    );
  }
}
