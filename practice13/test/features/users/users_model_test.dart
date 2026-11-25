import 'package:flutter_test/flutter_test.dart';
import 'package:where_things_go/core/api/api_exception.dart';
import 'package:where_things_go/features/users/users_model.dart';

import '../../fakes/fake_user_repository.dart';

void main() {
  group('UsersModel.load', () {
    test('publishes the two fake users', () async {
      final model = UsersModel(FakeUserRepository());
      addTearDown(model.dispose);

      await model.load();

      expect(model.items, hasLength(2));
      expect(model.loading, isFalse);
      expect(model.error, isNull);
    });

    test('NoConnection sets error', () async {
      final model = UsersModel(FakeUserRepository(fail: true));
      addTearDown(model.dispose);

      await model.load();

      expect(model.error, isA<NoConnectionException>());
      expect(model.loading, isFalse);
    });
  });
}
