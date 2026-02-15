part of 'announcement_form_cubit.dart';

enum AnnouncementFormStatus { initial, submitting, success, failure }

final class AnnouncementFormState extends Equatable {
  const AnnouncementFormState({
    this.status = AnnouncementFormStatus.initial,
    this.errorMessage,
  });

  final AnnouncementFormStatus status;
  final String? errorMessage;

  AnnouncementFormState copyWith({
    AnnouncementFormStatus? status,
    String? errorMessage,
  }) {
    return AnnouncementFormState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
