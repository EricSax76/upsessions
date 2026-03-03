import 'package:cloud_firestore/cloud_firestore.dart';

import 'announcement_entity.dart';
import 'announcement_enums.dart';

class AnnouncementDto {
  const AnnouncementDto({
    required this.id,
    required this.title,
    required this.body,
    required this.city,
    required this.author,
    required this.authorId,
    required this.province,
    required this.instrument,
    required this.styles,
    required this.publishedAt,
    this.imageUrl,
    // ── Campos normativos ──────────────────────────────────────────
    this.expiresAt,
    this.updatedAt,
    this.isActive = true,
    this.contactMethod,
    this.budget,
    this.contractType,
    this.requiredExperienceYears,
    this.locationRemote = false,
  });

  factory AnnouncementDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AnnouncementDto(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      body: (data['body'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      author: (data['author'] ?? '') as String,
      authorId: (data['authorId'] ?? '') as String,
      province: (data['province'] ?? '') as String,
      instrument: (data['instrument'] ?? '') as String,
      styles: _stringList(data['styles']),
      publishedAt: _parseDate(data['publishedAt']),
      imageUrl: data['imageUrl'] as String?,
      // ── Campos normativos ──────────────────────────────────────────
      expiresAt: _parseOptionalDate(data['expiresAt']),
      updatedAt: _parseOptionalDate(data['updatedAt']),
      isActive: (data['isActive'] as bool?) ?? true,
      contactMethod: _parseContactMethod(data['contactMethod']),
      budget: data['budget'] as String?,
      contractType: _parseContractType(data['contractType']),
      requiredExperienceYears: data['requiredExperienceYears'] as int?,
      locationRemote: (data['locationRemote'] as bool?) ?? false,
    );
  }

  factory AnnouncementDto.fromEntity(AnnouncementEntity entity) {
    return AnnouncementDto(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      city: entity.city,
      author: entity.author,
      authorId: entity.authorId,
      province: entity.province,
      instrument: entity.instrument,
      styles: entity.styles,
      publishedAt: entity.publishedAt,
      imageUrl: entity.imageUrl,
      expiresAt: entity.expiresAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      contactMethod: entity.contactMethod,
      budget: entity.budget,
      contractType: entity.contractType,
      requiredExperienceYears: entity.requiredExperienceYears,
      locationRemote: entity.locationRemote,
    );
  }

  final String id;
  final String title;
  final String body;
  final String city;
  final String author;
  final String authorId;
  final String province;
  final String instrument;
  final List<String> styles;
  final DateTime publishedAt;
  final String? imageUrl;

  // ── Campos normativos ────────────────────────────────────────────
  final DateTime? expiresAt;
  final DateTime? updatedAt;
  final bool isActive;
  final ContactMethod? contactMethod;
  final String? budget;
  final AnnouncementContractType? contractType;
  final int? requiredExperienceYears;
  final bool locationRemote;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'city': city,
      'author': author,
      'authorId': authorId,
      'province': province,
      'instrument': instrument,
      'styles': styles,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'isActive': isActive,
      'locationRemote': locationRemote,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (contactMethod != null) 'contactMethod': contactMethod!.name,
      if (budget != null && budget!.isNotEmpty) 'budget': budget,
      if (contractType != null) 'contractType': contractType!.name,
      if (requiredExperienceYears != null)
        'requiredExperienceYears': requiredExperienceYears,
    };
  }

  AnnouncementEntity toEntity() {
    return AnnouncementEntity(
      id: id,
      title: title,
      body: body,
      city: city,
      author: author,
      authorId: authorId,
      province: province,
      instrument: instrument,
      styles: styles,
      publishedAt: publishedAt,
      imageUrl: imageUrl,
      expiresAt: expiresAt,
      updatedAt: updatedAt,
      isActive: isActive,
      contactMethod: contactMethod,
      budget: budget,
      contractType: contractType,
      requiredExperienceYears: requiredExperienceYears,
      locationRemote: locationRemote,
    );
  }

  // ── Helpers de parseo ────────────────────────────────────────────

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static DateTime? _parseOptionalDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is Iterable) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  static ContactMethod? _parseContactMethod(dynamic raw) {
    if (raw is! String) return null;
    return ContactMethod.values.where((e) => e.name == raw).firstOrNull;
  }

  static AnnouncementContractType? _parseContractType(dynamic raw) {
    if (raw is! String) return null;
    return AnnouncementContractType.values
        .where((e) => e.name == raw)
        .firstOrNull;
  }
}
