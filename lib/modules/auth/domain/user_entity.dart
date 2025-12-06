import 'package:flutter/foundation.dart';

@immutable
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isVerified = false,
  });

  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isVerified;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
