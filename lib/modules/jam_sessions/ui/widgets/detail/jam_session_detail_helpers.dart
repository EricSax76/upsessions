import '../../../models/jam_session_entity.dart';
import '../../../../venues/models/venue_entity.dart';

String formatJamSessionDate(DateTime? date, String time) {
  if (date == null) return 'Fecha por definir';
  final dd = date.day.toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final yyyy = date.year.toString();
  final cleanTime = time.trim();
  if (cleanTime.isEmpty) return '$dd/$mm/$yyyy';
  return '$dd/$mm/$yyyy • $cleanTime';
}

String buildJamSessionLocationLabel(
  JamSessionEntity session,
  VenueEntity? venue,
) {
  if (venue != null) {
    final cityLabel = [
      venue.city.trim(),
      venue.province.trim(),
    ].where((part) => part.isNotEmpty).join(', ');
    if (cityLabel.isEmpty) return venue.name;
    return '$cityLabel • ${venue.name}';
  }

  final city = session.city.trim();
  final province = (session.province ?? '').trim();
  final location = session.location.trim();
  final cityLabel = [
    if (city.isNotEmpty) city,
    if (province.isNotEmpty) province,
  ].join(', ');
  if (cityLabel.isEmpty) return location;
  if (location.isEmpty) return cityLabel;
  return '$cityLabel • $location';
}

String buildVenueAddressLabel(VenueEntity venue) {
  final location = [
    venue.address.trim(),
    venue.city.trim(),
    venue.province.trim(),
    (venue.postalCode ?? '').trim(),
  ].where((part) => part.isNotEmpty).join(', ');
  if (location.isNotEmpty) return location;
  return 'Direccion no disponible';
}
