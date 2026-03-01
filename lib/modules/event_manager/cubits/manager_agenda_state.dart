import 'package:equatable/equatable.dart';

class ManagerAgendaItem extends Equatable {
  const ManagerAgendaItem({
    required this.id,
    required this.title,
    required this.date,
    required this.type, // 'Event' or 'Jam Session'
    this.city,
    this.location,
  });

  final String id;
  final String title;
  final DateTime date;
  final String type;
  final String? city;
  final String? location;

  @override
  List<Object?> get props => [id, title, date, type, city, location];
}

class ManagerAgendaState extends Equatable {
  const ManagerAgendaState({
    this.items = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<ManagerAgendaItem> items;
  final bool isLoading;
  final String? errorMessage;

  ManagerAgendaState copyWith({
    List<ManagerAgendaItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ManagerAgendaState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, errorMessage];
}
