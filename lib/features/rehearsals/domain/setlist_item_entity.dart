import 'package:equatable/equatable.dart';

class SetlistItemEntity extends Equatable {
  const SetlistItemEntity({
    required this.id,
    required this.order,
    required this.songId,
    required this.songTitle,
    required this.keySignature,
    required this.tempoBpm,
    required this.notes,
  });

  final String id;
  final int order;
  final String? songId;
  final String? songTitle;
  final String keySignature;
  final int? tempoBpm;
  final String notes;

  String get displayTitle => (songTitle?.trim().isNotEmpty == true)
      ? songTitle!.trim()
      : (songId?.trim().isNotEmpty == true ? 'Song $songId' : 'Sin título');

  @override
  List<Object?> get props => [
    id,
    order,
    songId,
    songTitle,
    keySignature,
    tempoBpm,
    notes,
  ];
}

