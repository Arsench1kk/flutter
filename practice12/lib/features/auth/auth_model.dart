import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {required String? token}) : _signedIn = token != null;

  final SecureStore _store;
  bool _signedIn;

  bool get signedIn => _signedIn;

  Future<void> login(String email, String password) async {
    if (password.length < 8) {
      throw ArgumentError('The password must have at least eight characters.');
    }
    await Future<void>.delayed(const Duration(seconds: 1));
    await _store.saveToken('tok_${email.hashCode}');
    _signedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _signedIn = false;
    notifyListeners();
  }
}
