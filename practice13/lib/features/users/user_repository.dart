import 'user.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

abstract interface class UserRepository {
  Future<UsersResult> getAll();
  Future<User> getById(int id);
  Future<User> create(User draft);
  Future<List<User>?> readCached();
  void close();
}
