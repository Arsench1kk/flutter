import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  const UsersCache();

  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File.fromUri(directory.uri.resolve('users.json'));
  }

  Future<void> save(List<User> users) async {
    final file = await _file();
    final scratch = await file.parent.createTemp('users-cache-');
    try {
      final pending = File.fromUri(scratch.uri.resolve('users.json'));
      await pending.writeAsString(
        jsonEncode([for (final user in users) user.toJson()]),
        flush: true,
      );
      await pending.rename(file.path);
    } finally {
      await scratch.delete(recursive: true);
    }
  }

  Future<List<User>?> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is! List) return null;
      return [
        for (final item in json) User.fromJson(item as Map<String, dynamic>),
      ];
    } on FileSystemException {
      return null;
    } on MissingPlatformDirectoryException {
      return null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
