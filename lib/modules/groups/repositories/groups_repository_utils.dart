part of 'groups_repository.dart';

Map<String, dynamic> _memberData({
  required String uid,
  required String role,
  required String addedBy,
  String? inviteId,
}) {
  return {
    'userId': uid,
    'ownerId': uid,
    'role': role,
    'status': 'active',
    'createdAt': FieldValue.serverTimestamp(),
    'addedBy': addedBy,
    if (inviteId != null) 'inviteId': inviteId,
  };
}

String _normalizeImageExtension(String? input) {
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
