import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDoc {
  const GroupDoc({
    required this.id,
    required this.name,
    required this.ownerId,
    this.genre = '',
    this.link1 = '',
    this.link2 = '',
    this.photoUrl = '',
  });

  final String id;
  final String name;
  final String ownerId;
  final String genre;
  final String link1;
  final String link2;
  final String photoUrl;

  factory GroupDoc.fromGroupDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return GroupDoc(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      ownerId: (data['ownerId'] ?? '').toString(),
      genre: (data['genre'] ?? '').toString(),
      link1: (data['link1'] ?? '').toString(),
      link2: (data['link2'] ?? '').toString(),
      photoUrl: (data['photoUrl'] ?? '').toString(),
    );
  }
}

class MembershipDoc {
  const MembershipDoc({required this.groupId, required this.role});

  final String groupId;
  final String role;

  factory MembershipDoc.fromMemberDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final groupId = doc.reference.parent.parent?.id ?? '';
    final data = doc.data();
    return MembershipDoc(
      groupId: groupId,
      role: (data['role'] ?? 'member').toString(),
    );
  }
}
