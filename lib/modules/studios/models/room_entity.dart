import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  const RoomEntity({
    required this.id,
    required this.studioId,
    required this.name,
    required this.capacity,
    required this.size,
    required this.equipment,
    required this.amenities,
    required this.pricePerHour,
    required this.photos,
  });

  final String id;
  final String studioId;
  final String name;
  final int capacity;
  final String size;
  final List<String> equipment;
  final List<String> amenities;
  final double pricePerHour;
  final List<String> photos;

  @override
  List<Object?> get props => [
        id,
        studioId,
        name,
        capacity,
        size,
        equipment,
        amenities,
        pricePerHour,
        photos,
      ];

  RoomEntity copyWith({
    String? id,
    String? studioId,
    String? name,
    int? capacity,
    String? size,
    List<String>? equipment,
    List<String>? amenities,
    double? pricePerHour,
    List<String>? photos,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      studioId: studioId ?? this.studioId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      size: size ?? this.size,
      equipment: equipment ?? this.equipment,
      amenities: amenities ?? this.amenities,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      photos: photos ?? this.photos,
    );
  }
}
