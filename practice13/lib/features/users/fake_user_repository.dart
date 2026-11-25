import '../../core/api/api_exception.dart';
import 'address.dart';
import 'geo.dart';
import 'user.dart';
import 'user_repository.dart';

class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;
  final List<User> _users = [..._exampleUsers];
  int _nextId = 3;

  @override
  Future<UsersResult> getAll() async {
    await _waitForResponse();
    return (items: List<User>.unmodifiable(_users), fromCache: false);
  }

  @override
  Future<User> getById(int id) async {
    await _waitForResponse();
    return _users.where((user) => user.id == id).firstOrNull ??
        (throw const NotFoundException());
  }

  @override
  Future<User> create(User draft) async {
    await _waitForResponse();
    final user = User.fromJson({...draft.toJson(), 'id': _nextId++});
    _users.insert(0, user);
    return user;
  }

  Future<void> _waitForResponse() async {
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    if (fail) throw const NoConnectionException();
  }

  @override
  Future<List<User>?> readCached() async => null;

  @override
  void close() {}

  static const _exampleUsers = [
    User(
      id: 1,
      name: 'Amina Sadykova',
      username: 'amina',
      email: 'amina@example.com',
      phone: '+7 700 000 0001',
      address: Address(
        street: 'Abay Avenue',
        suite: '',
        city: 'Almaty',
        zipcode: '050000',
        geo: Geo(lat: 43.2389, lng: 76.8897),
      ),
      company: (name: 'Example Studio', catchPhrase: 'Design for everyone'),
      companyBusiness: 'Design',
    ),
    User(
      id: 2,
      name: 'Daniyar Karimov',
      username: 'daniyar',
      email: 'daniyar@example.com',
      phone: '+7 700 000 0002',
      address: Address(
        street: 'Turan Avenue',
        suite: '',
        city: 'Astana',
        zipcode: '010000',
        geo: Geo(lat: 51.1694, lng: 71.4491),
      ),
      company: (name: 'Example Labs', catchPhrase: 'Build and learn'),
      companyBusiness: 'Software',
    ),
  ];
}
