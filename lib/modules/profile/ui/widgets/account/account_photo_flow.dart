import 'package:image_picker/image_picker.dart';

class AccountPhotoFlow {
  AccountPhotoFlow({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickProfilePhoto(ImageSource source) {
    return _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxHeight: 1200,
      maxWidth: 1200,
    );
  }

  static String extensionFromName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return 'jpg';
  }
}
