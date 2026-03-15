class RehearsalBookingContext {
  const RehearsalBookingContext({
    required this.groupId,
    required this.rehearsalId,
    required this.suggestedDate,
    this.suggestedEndDate,
  });

  final String groupId;
  final String rehearsalId;
  final DateTime suggestedDate;
  final DateTime? suggestedEndDate;
}
