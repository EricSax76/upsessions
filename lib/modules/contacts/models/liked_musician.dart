import 'package:flutter/foundation.dart';

@immutable
class LikedMusician {
  const LikedMusician({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.instrument,
    required this.city,
    required this.styles,
    this.highlightStyle,
    this.photoUrl,
    this.experienceYears = 0,
    this.rating,
  });

  final String id;
  final String ownerId;
  final String name;
  final String instrument;
  final String city;
  final List<String> styles;
  final String? highlightStyle;
  final String? photoUrl;
  final int experienceYears;
  final double? rating;

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final buffer = StringBuffer();
    for (final part in parts.take(2)) {
      buffer.write(part[0]);
    }
    final result = buffer.toString();
    return result.isEmpty ? '?' : result.toUpperCase();
  }

  List<String> get nonEmptyStyles {
    if (styles.isNotEmpty) {
      return styles;
    }
    if (highlightStyle != null && highlightStyle!.isNotEmpty) {
      return [highlightStyle!];
    }
    return const [];
  }

  LikedMusician copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? instrument,
    String? city,
    List<String>? styles,
    String? highlightStyle,
    String? photoUrl,
    int? experienceYears,
    double? rating,
  }) {
    return LikedMusician(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      instrument: instrument ?? this.instrument,
      city: city ?? this.city,
      styles: styles ?? this.styles,
      highlightStyle: highlightStyle ?? this.highlightStyle,
      photoUrl: photoUrl ?? this.photoUrl,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
    );
  }
}
