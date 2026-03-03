import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDoc {
  const GroupDoc({
    required this.id,
    required this.name,
    required this.ownerId,
    // ── Campos legacy (retrocompatibilidad) ────────────────────────
    this.genre = '',
    this.link1 = '',
    this.link2 = '',
    // ── Campos nuevos ──────────────────────────────────────────────
    this.description = '',
    this.genres = const [],
    this.city,
    this.province,
    this.isActive = true,
    this.photoUrl = '',
    this.links = const {},
    this.foundedAt,
    this.createdAt,
    this.updatedAt,
    this.sgaeGroupCode,
    this.internalRevenueShare,
  });

  factory GroupDoc.fromGroupDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    // ── Campos legacy: genre (String) ──────────────────────────────
    final legacyGenre = (data['genre'] ?? '').toString();

    // ── genres: List<String> — prioriza el nuevo campo, fallback al legacy ──
    final List<String> genres;
    if (data['genres'] is List) {
      genres = (data['genres'] as List).map((e) => e.toString()).toList();
    } else if (legacyGenre.isNotEmpty) {
      genres = [legacyGenre];
    } else {
      genres = const [];
    }

    // ── links: Map<String, String> — prioriza el nuevo campo, fallback a link1/link2 ──
    final String link1 = (data['link1'] ?? '').toString();
    final String link2 = (data['link2'] ?? '').toString();
    final Map<String, String> links;
    if (data['links'] is Map) {
      links = Map<String, String>.from(
        (data['links'] as Map).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ),
      );
    } else {
      links = {
        if (link1.isNotEmpty) 'link1': link1,
        if (link2.isNotEmpty) 'link2': link2,
      };
    }

    // ── internalRevenueShare ───────────────────────────────────────
    Map<String, double>? revenueShare;
    if (data['internalRevenueShare'] is Map) {
      revenueShare = Map<String, double>.from(
        (data['internalRevenueShare'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      );
    }

    return GroupDoc(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      ownerId: (data['ownerId'] ?? '').toString(),
      genre: legacyGenre,
      link1: link1,
      link2: link2,
      description: (data['description'] ?? '').toString(),
      genres: genres,
      city: data['city'] as String?,
      province: data['province'] as String?,
      isActive: (data['isActive'] as bool?) ?? true,
      photoUrl: (data['photoUrl'] ?? '').toString(),
      links: links,
      foundedAt: _parseOptionalDate(data['foundedAt']),
      createdAt: _parseOptionalDate(data['createdAt']),
      updatedAt: _parseOptionalDate(data['updatedAt']),
      sgaeGroupCode: data['sgaeGroupCode'] as String?,
      internalRevenueShare: revenueShare,
    );
  }

  // ── Campos legacy ────────────────────────────────────────────────
  final String id;
  final String name;
  final String ownerId;
  final String genre;
  final String link1;
  final String link2;

  // ── Campos nuevos ────────────────────────────────────────────────
  final String description;
  final List<String> genres;
  final String? city;
  final String? province;
  final bool isActive;
  final String photoUrl;
  final Map<String, String> links;
  final DateTime? foundedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? sgaeGroupCode;
  final Map<String, double>? internalRevenueShare;

  static DateTime? _parseOptionalDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

class MembershipDoc {
  const MembershipDoc({required this.groupId, required this.role});

  final String groupId;
  final String role;

  factory MembershipDoc.fromMemberDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final groupId = doc.reference.parent.parent?.id ?? '';
    final data = doc.data();
    return MembershipDoc(
      groupId: groupId,
      role: (data['role'] ?? 'member').toString(),
    );
  }
}

