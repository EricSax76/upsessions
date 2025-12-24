String normalizeImageExtension(String? input) {
  final normalized = (input ?? '').toLowerCase().replaceAll('.', '');
  if (normalized.isEmpty) return 'jpeg';
  switch (normalized) {
    case 'jpg':
    case 'jpeg':
      return 'jpeg';
    case 'png':
    case 'gif':
    case 'webp':
      return normalized;
    default:
      return 'jpeg';
  }
}
