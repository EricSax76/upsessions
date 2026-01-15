part of 'groups_repository.dart';

mixin GroupsRepositoryGroups on RehearsalsRepositoryBase {
  FirebaseStorage get storage;

  Future<String> createGroup({
    required String name,
    String? genre,
    String? link1,
    String? link2,
    Uint8List? photoBytes,
    String? photoFileExtension,
  }) async {
    final uid = await requireMusicianUid();
    logFirestore('createGroup ownerId=$uid name="${name.trim()}"');
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('El nombre del grupo es obligatorio.');
    }

    final newGroupDoc = groups().doc();
    final memberDoc = members(newGroupDoc.id).doc(uid);
    final batch = firestore.batch();
    batch.set(newGroupDoc, {
      'groupId': newGroupDoc.id,
      'name': trimmedName,
      'ownerId': uid,
      'genre': (genre ?? '').trim(),
      'link1': (link1 ?? '').trim(),
      'link2': (link2 ?? '').trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(memberDoc, _memberData(uid: uid, role: 'owner', addedBy: uid));
    await logFuture('createGroup commit', batch.commit());

    final bytes = photoBytes;
    if (bytes != null && bytes.isNotEmpty) {
      final ext = _normalizeImageExtension(photoFileExtension);
      final ref = storage
          .ref()
          .child('groups')
          .child(newGroupDoc.id)
          .child('photo.$ext');
      final metadata = SettableMetadata(contentType: 'image/$ext');
      await ref.putData(bytes, metadata);
      final photoUrl = await ref.getDownloadURL();
      await newGroupDoc.set({'photoUrl': photoUrl}, SetOptions(merge: true));
    }

    return newGroupDoc.id;
  }

  Future<void> deleteGroup({required String groupId}) async {
    final uid = requireUid();
    logFirestore('deleteGroup groupId=$groupId uid=$uid');
    final groupRef = groupDoc(groupId);
    final groupSnap = await groupRef.get();
    final group = groupSnap.data() ?? <String, dynamic>{};
    final ownerId = (group['ownerId'] ?? '').toString();
    if (ownerId != uid) {
      throw Exception('Solo el dueño puede eliminar el grupo.');
    }

    final batch = firestore.batch();

    final membersSnap = await members(groupId).get();
    for (final doc in membersSnap.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(groupRef);

    await logFuture('deleteGroup commit', batch.commit());
  }

  Future<void> updateGroupPhoto({
    required String groupId,
    required Uint8List photoBytes,
    required String photoFileExtension,
  }) async {
    final uid = await requireMusicianUid();
    logFirestore('updateGroupPhoto groupId=$groupId uid=$uid');

    // Verificar permisos (solo owner o admin)
    final memberDoc = await members(groupId).doc(uid).get();
    if (!memberDoc.exists) throw Exception('No eres miembro de este grupo.');
    final role = (memberDoc.data()?['role'] ?? '').toString();
    if (role != 'owner' && role != 'admin') {
      throw Exception('No tienes permisos para cambiar la foto del grupo.');
    }

    final ext = _normalizeImageExtension(photoFileExtension);
    final ref = storage.ref().child('groups').child(groupId).child('photo.$ext');
    final metadata = SettableMetadata(contentType: 'image/$ext');

    await ref.putData(photoBytes, metadata);
    final photoUrl = await ref.getDownloadURL();

    await groupDoc(groupId).set({'photoUrl': photoUrl}, SetOptions(merge: true));
  }
}
