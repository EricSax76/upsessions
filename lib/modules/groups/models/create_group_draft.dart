import 'dart:typed_data';

class CreateGroupDraft {
  const CreateGroupDraft({
    required this.name,
    required this.genre,
    required this.link1,
    required this.link2,
    required this.photoBytes,
    required this.photoFileExtension,
    this.description = '',
    this.city,
    this.province,
    this.sgaeGroupCode,
  });

  final String name;
  final String genre;
  final String link1;
  final String link2;
  final Uint8List? photoBytes;
  final String? photoFileExtension;

  // ── Campos normativos ──────────────────────────────────────────
  final String description;
  final String? city;
  final String? province;
  final String? sgaeGroupCode;
}
