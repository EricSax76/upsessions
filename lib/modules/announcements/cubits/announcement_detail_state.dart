part of 'announcement_detail_cubit.dart';

enum AnnouncementDetailStatus { initial, contacting, success, failure }

final class AnnouncementDetailState extends Equatable {
  const AnnouncementDetailState({
    this.status = AnnouncementDetailStatus.initial,
    this.threadId,
    this.errorMessage,
  });

  final AnnouncementDetailStatus status;
  final String? threadId;
  final String? errorMessage;

  AnnouncementDetailState copyWith({
    AnnouncementDetailStatus? status,
    String? threadId,
    String? errorMessage,
  }) {
    return AnnouncementDetailState(
      status: status ?? this.status,
      threadId: threadId ?? this.threadId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, threadId, errorMessage];
}
