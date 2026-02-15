import 'package:equatable/equatable.dart';

import '../models/liked_musician.dart';

enum LikedMusiciansStatus { initial, loading, loaded, error }

class LikedMusiciansState extends Equatable {
  const LikedMusiciansState({
    this.status = LikedMusiciansStatus.initial,
    this.contacts = const {},
    this.errorMessage,
  });

  final LikedMusiciansStatus status;
  final Map<String, LikedMusician> contacts;
  final String? errorMessage;

  List<LikedMusician> get sortedContacts {
    final items = contacts.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(items);
  }

  bool isLiked(String id) => contacts.containsKey(id);

  int get total => contacts.length;

  LikedMusiciansState copyWith({
    LikedMusiciansStatus? status,
    Map<String, LikedMusician>? contacts,
    String? errorMessage,
  }) {
    return LikedMusiciansState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, contacts, errorMessage];
}
