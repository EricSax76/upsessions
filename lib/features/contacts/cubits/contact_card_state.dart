import 'package:equatable/equatable.dart';

enum ContactCardStatus { idle, contacting, success, error }

class ContactCardState extends Equatable {
  const ContactCardState({
    this.status = ContactCardStatus.idle,
    this.threadId,
    this.errorMessage,
  });

  final ContactCardStatus status;
  final String? threadId;
  final String? errorMessage;

  bool get isContacting => status == ContactCardStatus.contacting;

  ContactCardState copyWith({
    ContactCardStatus? status,
    String? threadId,
    String? errorMessage,
  }) {
    return ContactCardState(
      status: status ?? this.status,
      threadId: threadId ?? this.threadId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, threadId, errorMessage];
}
