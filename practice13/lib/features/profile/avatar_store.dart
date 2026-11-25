import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarStore {
  const AvatarStore(this._prefs);

  static const _avatarKey = 'avatarPath';
  static const _fileName = 'avatar.jpg';

  final SharedPreferencesAsync _prefs;

  Future<File?> load() async {
    final path = await _prefs.getString(_avatarKey) ?? '';
    if (path.isEmpty || Uri.file(path).pathSegments.lastOrNull != _fileName) {
      return null;
    }
    try {
      final documents = await getApplicationDocumentsDirectory();
      final file = File.fromUri(documents.uri.resolve(_fileName));
      return await file.exists() ? file : null;
    } on FileSystemException {
      return null;
    } on MissingPlatformDirectoryException {
      return null;
    }
  }

  Future<File> save(XFile photo) async {
    final documents = await getApplicationDocumentsDirectory();
    final destination = File.fromUri(documents.uri.resolve(_fileName));
    final scratch = await documents.createTemp('avatar-');
    try {
      final pending = File.fromUri(scratch.uri.resolve(_fileName));
      await photo.saveTo(pending.path);
      await pending.rename(destination.path);
    } finally {
      await scratch.delete(recursive: true);
    }
    // The OS can relocate the app container between installs or updates.
    await _prefs.setString(_avatarKey, _fileName);
    return destination;
  }

  Future<void> recoverAndroidPhoto() async {
    if (!Platform.isAndroid) return;
    final result = await ImagePicker().retrieveLostData();
    final photo = result.files?.firstOrNull;
    if (photo != null) await save(photo);
  }
}
