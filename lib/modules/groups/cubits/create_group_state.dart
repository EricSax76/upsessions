import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class CreateGroupState extends Equatable {
  const CreateGroupState({
    this.photoBytes,
    this.photoExtension,
    this.isPickingPhoto = false,
  });

  final Uint8List? photoBytes;
  final String? photoExtension;
  final bool isPickingPhoto;

  CreateGroupState copyWith({
    Uint8List? photoBytes,
    String? photoExtension,
    bool? isPickingPhoto,
    bool clearPhoto = false,
  }) {
    return CreateGroupState(
      photoBytes: clearPhoto ? null : (photoBytes ?? this.photoBytes),
      photoExtension:
          clearPhoto ? null : (photoExtension ?? this.photoExtension),
      isPickingPhoto: isPickingPhoto ?? this.isPickingPhoto,
    );
  }

  @override
  List<Object?> get props => [photoBytes, photoExtension, isPickingPhoto];
}
