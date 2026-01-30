import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/locator/locator.dart';
import '../models/group_dtos.dart';
import '../repositories/groups_repository.dart';

class GroupPageController {
  GroupPageController({
    GroupsRepository? groupsRepository,
    ImagePicker? imagePicker,
  }) : _groupsRepository = groupsRepository ?? locate<GroupsRepository>(),
       _imagePicker = imagePicker ?? ImagePicker();

  final GroupsRepository _groupsRepository;
  final ImagePicker _imagePicker;

  Stream<GroupDoc> watchGroup(String groupId) {
    return _groupsRepository.watchGroup(groupId);
  }

  Future<XFile?> pickGroupPhoto(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    return _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  Future<void> uploadGroupPhoto({
    required String groupId,
    required XFile image,
  }) async {
    final bytes = await image.readAsBytes();
    final ext = image.path.split('.').last;

    await _groupsRepository.updateGroupPhoto(
      groupId: groupId,
      photoBytes: bytes,
      photoFileExtension: ext,
    );
  }
}
