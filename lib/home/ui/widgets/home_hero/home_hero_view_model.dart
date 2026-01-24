import '../../../../modules/rehearsals/cubits/rehearsal_entity.dart';

class HomeHeroViewModel {
  HomeHeroViewModel({
    required this.displayName,
    required this.photoUrl,
    required this.nextRehearsal,
  })  : titleName = displayName.trim().isEmpty ? '' : displayName.trim(),
        initials = _initialsFromName(displayName);

  final String displayName;
  final String titleName;
  final String initials;
  final String? photoUrl;
  final RehearsalEntity? nextRehearsal;

  static String _initialsFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1);
    }
    final first = parts.first.isEmpty ? '' : parts.first.substring(0, 1);
    final last = parts.last.isEmpty ? '' : parts.last.substring(0, 1);
    return '$first$last';
  }
}
