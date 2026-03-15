import 'package:cloud_firestore/cloud_firestore.dart';

/// Helpers de parsing para deserializar documentos Firestore en [MusicianDto].

DateTime? toDateTime(dynamic raw) {
  if (raw is Timestamp) return raw.toDate();
  if (raw is String) return DateTime.tryParse(raw);
  return null;
}

List<String> toStringList(dynamic raw) {
  if (raw is Iterable) return raw.map((e) => e.toString()).toList();
  return const [];
}

String? firstNonEmptyString(List<dynamic> candidates) {
  for (final candidate in candidates) {
    if (candidate is String) {
      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }
  return null;
}
