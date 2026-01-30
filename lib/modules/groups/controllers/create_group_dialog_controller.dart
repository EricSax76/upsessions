import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/create_group_draft.dart';

class CreateGroupDialogController extends ChangeNotifier {
  CreateGroupDialogController({ImagePicker? picker})
    : _picker = picker ?? ImagePicker() {
    _nameController.addListener(_handleNameChanged);
  }

  static const _photoQuality = 80;
  static const _photoMaxSize = 1600.0;

  final ImagePicker _picker;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _link1Controller = TextEditingController();
  final TextEditingController _link2Controller = TextEditingController();

  Uint8List? _photoBytes;
  String? _photoExtension;
  bool _pickingPhoto = false;
  bool _disposed = false;

  TextEditingController get nameController => _nameController;
  TextEditingController get genreController => _genreController;
  TextEditingController get link1Controller => _link1Controller;
  TextEditingController get link2Controller => _link2Controller;

  Uint8List? get photoBytes => _photoBytes;
  String? get photoExtension => _photoExtension;
  bool get isPickingPhoto => _pickingPhoto;

  bool get canSubmit =>
      _nameController.text.trim().isNotEmpty && !_pickingPhoto;

  Future<void> pickPhoto(ImageSource source) async {
    if (_pickingPhoto || _disposed) return;
    _setPickingPhoto(true);
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: _photoQuality,
        maxHeight: _photoMaxSize,
        maxWidth: _photoMaxSize,
      );
      if (file == null || _disposed) return;
      final bytes = await file.readAsBytes();
      if (_disposed) return;
      _photoBytes = bytes;
      _photoExtension = _extensionFromName(file.name);
      _notify();
    } finally {
      _setPickingPhoto(false);
    }
  }

  void clearPhoto() {
    if (_photoBytes == null && _photoExtension == null) return;
    _photoBytes = null;
    _photoExtension = null;
    _notify();
  }

  CreateGroupDraft buildDraft() {
    return CreateGroupDraft(
      name: _nameController.text.trim(),
      genre: _genreController.text.trim(),
      link1: _link1Controller.text.trim(),
      link2: _link2Controller.text.trim(),
      photoBytes: _photoBytes,
      photoFileExtension: _photoExtension,
    );
  }

  void _handleNameChanged() {
    _notify();
  }

  void _setPickingPhoto(bool value) {
    if (_pickingPhoto == value) return;
    _pickingPhoto = value;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  static String _extensionFromName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return 'jpg';
  }

  @override
  void dispose() {
    _disposed = true;
    _nameController.removeListener(_handleNameChanged);
    _nameController.dispose();
    _genreController.dispose();
    _link1Controller.dispose();
    _link2Controller.dispose();
    super.dispose();
  }
}
