import '../../../../../../modules/event_manager/models/event_manager_entity.dart';

String buildManagerInitials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2)
      .toList(growable: false);
  if (words.isEmpty) return '';
  return words.map((word) => word[0].toUpperCase()).join();
}

String managerCityLabel(EventManagerEntity manager) {
  final city = manager.city.trim();
  final province = (manager.province ?? '').trim();
  if (city.isEmpty && province.isEmpty) return 'No disponible';
  if (province.isEmpty) return city;
  if (city.isEmpty) return province;
  return '$city, $province';
}
