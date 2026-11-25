import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;
  List<User> _items = const [];
  ApiException? _error;
  bool _loading = false;
  bool _fromCache = false;
  bool _disposed = false;

  List<User> get items => _items;
  ApiException? get error => _error;
  bool get loading => _loading;
  bool get fromCache => _fromCache;

  List<String> get cities => {
    for (final user in _items)
      if (user.address.city.isNotEmpty) user.address.city,
  }.toList()..sort();

  Future<void> load() async {
    if (_loading || _disposed) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (_items.isEmpty && !_fromCache) {
        final cached = await _repo.readCached();
        if (_disposed) return;
        if (cached != null) {
          _items = List.unmodifiable(cached);
          _fromCache = true;
          notifyListeners();
        }
      }
      final result = await _repo.getAll();
      _items = List.unmodifiable(result.items);
      _fromCache = result.fromCache;
    } on ApiException catch (error) {
      _error = error;
      _fromCache = false;
    } finally {
      _loading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<User> create(User draft) async {
    final user = await _repo.create(draft);
    if (!_disposed) {
      _items = List.unmodifiable([
        user,
        ..._items.where((u) => u.id != user.id),
      ]);
      notifyListeners();
    }
    return user;
  }

  @override
  void dispose() {
    _disposed = true;
    _repo.close();
    super.dispose();
  }
}
