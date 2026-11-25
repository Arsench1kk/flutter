import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs, {required this._dark, required this._city});

  static const darkKey = 'darkMode';
  static const cityKey = 'cityFilter';

  final SharedPreferencesAsync _prefs;
  bool _dark;
  String? _city;
  Future<void> _pendingWrite = Future.value();

  bool get dark => _dark;
  String? get city => _city;

  Future<void> setDark(bool value) async {
    _dark = value;
    notifyListeners();
    await _persist(() => _prefs.setBool(darkKey, value));
  }

  Future<void> setCity(String? city) async {
    _city = city;
    notifyListeners();
    await _persist(
      () => city == null
          ? _prefs.remove(cityKey)
          : _prefs.setString(cityKey, city),
    );
  }

  Future<void> _persist(Future<void> Function() write) {
    final result = _pendingWrite.then((_) => write());
    _pendingWrite = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}
